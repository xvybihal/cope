#!/usr/bin/env perl
package App::Cope;
use strict;
use warnings;
use 5.010_000;
no if $] >= 5.018, warnings => "experimental";
use Carp;

our $VERSION = '0.99';

=head1 NAME

App::Cope - Functions for the B<cope> program

=head1 SYNOPSIS

B<Note:> This file contains functions for L<cope>, and documentation
on its internals. If you want to learn how to use or install cope
itself, see L<App::Cope::Manual> instead.

=cut

use App::Cope::Pty;

use IO::Handle;
use Term::ANSIColor;
use List::MoreUtils qw[each_array firstidx];
use Env::Path qw[:all];
use File::Spec;
use feature ':5.10';

use base q[Exporter];
our @EXPORT = qw[run mark line real_path];
our @EXPORT_OK = qw[run_with get colourise];

sub import {
  # Automatically use strictures and warnings and Perl 5.10 features,
  # so those three lines don't have to be typed for every script
  strict->import;
  warnings->import;
  feature->import( ':5.10' );

  # Let Exporter do the rest
  App::Cope->export_to_level( 1, @_ );
}

=head1 HIGHLIGHTING

Rather embarrassingly, the technique for highlighting parts of a
string is used by modifying global variables. The process works
something like this:

1) cope gets a string from a program's output.

2) The L</"line"> and L</"mark"> functions match against the string,
   now in C<$_>, and modify the hash C<%colours> at the start and end
   positions of the match with ANSI control codes to turn the colours
   on and off.

3) The string is colourised, and the control-code-laden string is
   printed as output.

Previously, the two functions modified C<$_> throughout, but then it
was impossible to match against an already-coloured part of the
string, as the control codes would get in the way.

=head2 Buffering

The programs run are line-buffered by default - that is, cope waits
for it to output a newline before it starts processing the
string. This is so scripts can't receive half a line and accidentally
treat it as a whole one, instead of matching after all the line has
been received.

If your program regularly updates without a newline, you can turn this
behaviour off:

    $App::Cope::line_buffered = 0;    # or on again with 1

The side-effect of doing this is that you can no longer rely on
substrings to be processed in the same string, even if they appear
next to each other in the final output. In general, if there is a
pause between successive prints, the two will be treated as different
outputs.

=head1 MAIN FUNCTIONS

=head2 run( \&process, @args )

The main entry point for scripts to use - checks C<$NOCOPE> and the
resulting terminal, and then passes control to L<run_with>.

=cut

# Information about the path that is used quite often
my ( $vol, $dir, $file ) = File::Spec->splitpath($0);
my $script_path = File::Spec->catpath( $vol, $dir );
$script_path =~ s{/$}{};

sub run {
  my ( $process, @args ) = @_;
  croak "No arguments" unless @args;

  # Remove ourselves from the $PATH, so other scripts that recurse
  # like this don't go into an infinite loop
  PATH->Remove( $script_path );

  # Don't run if told not to, and always run if forced to
  if ( $ENV{NOCOPE} or ( not $ENV{COPE} and not POSIX::isatty STDOUT ) ) {
    exec @args;
  }
  else {
    my $ret_val = run_with( $process, @args );
	exit $ret_val;
  }
}

=head2 run_with( \&process, @args )

The main body of the program, when being run by scripts. It takes a
sub that modifies each line of input, and a list of arguments to pass
to exec to run the program. The first of the args, the program name,
should be absolute.

=cut

our %colours;                   # the variable to modify
our $line_buffered = 1;         # keep a buffer of half-lines
our $color_stack = 0;           # When applying colors, use a stack

sub run_with {
  my ( $process, @args ) = @_;

  # Initialise handle
  my $fh = new IO::Handle or croak "Failed handle: $!";
  $fh->fdopen( fileno STDIN, 'r' );
  $fh->autoflush;

  # Initialise pseudo-terminal
  my $pty = App::Cope::Pty->new;
  $pty->spawn( @args );

  # Let any signals be automatically passed to the child process
  my @signals = qw[INT QUIT TERM];
  my $dying_early = 0;
  for my $sig (@signals) {
    $SIG{$sig} = sub {
      $dying_early++;
      kill $sig => -$pty->{pid}; # kill the entire process group
    };
  }

  # No suffering from buffering
  local $| = 1;

  # Main loop: continues as long as there's input to receive
 receive:
  my $buf = '';
  while ( defined ( my $rout = $pty->read ) ) {
    my @bits = split /(\r|\n)/, "$buf$rout";
    if ( ( $line_buffered || $pty->more_to_read ) and $bits[-1] !~ /\r|\n/ ) {
      $buf = pop @bits;
    }
    else {
      $buf = '';
    }
    print colourise( $process, $_ ) for @bits;
  }

  if ($dying_early) {
    # The call to $pty->read was terminated by a signal! Try to read
    # any more output, in case there's any left to read.
    $dying_early = 0;
    goto receive;
  }

  $fh->close  or carp "Failed close: $!";
  $pty->close or carp "Failed close: $!";

  waitpid($pty->{pid}, 0);
  return ($? >> 8);
}

=head2 mark( $regex, $colour )

The simpler of the highlighting functions; C<mark> takes a regex, and
one colour, and highlights the first part of the string matched in the
given colour.

  mark qr{open} => 'green bold';

=cut

sub mark {
  my ( $regex, $colour ) = @_;
  if ( m/$regex/p ) {
    colour( $-[0], $+[0] => get( $colour, substr $_, $-[0], $+[0] - $-[0] ) );
    return 1;
  }
  return 0;
}

=head2 line( $regex, @colours )

The more complicated function; C<line> takes a regex, containing
parenthesised captures, and highlights each match with the relevant
colour in the array.

  line qr{^(\d+){/\w+)} => 'cyan bold', 'blue';

=cut

sub line {
  my $regex = shift;

  my $offset = 0;
  while ( m/$regex/g ) {

    # skip 0th entries - they just contain info about the entire match
    my @starts  = @-[ 1 .. $#- ];
    my @ends    = @+[ 1 .. $#+ ];
    my @colours = @_;

    my $ea = each_array( @starts, @ends, @colours );
    while ( my ( $start, $end, $colour ) = $ea->() ) {

      # either $start or $end being undef means that there was nothing to
      # match, e.g. /(?: (\S+) )?/x where the match fails.
      if ( defined $start and defined $end ) {
        my $before = substr $_, $start, $end - $start;
	my $c = get( $colour, $before );
	colour( $start, $end => $c );
      }
    }

    $offset += $+[0]; # mark everything up to here as done
  }

  return $offset; # still false if nothing's changed
}

=head1 HELPER FUNCTIONS

=head2 get( $colour, $str );

Returns a colour based on how a reference - an array, a hash, some
code, or just a scalar string - reacts to the text matched by a
regex. Used by C<mark> and C<line>.

  # simple scalar usage
  line qr/^Count: (\d+)/ => 'green';

  # passing a subroutine
  line qr/^Errors: (\d+)/ => sub {
    return 'red' if shift > 0;
  }

  # passing a hashref
  my %protocols = (
    'tcp'   => 'magenta',
    'udp'   => 'red',
    'raw'   => 'red bold',
    '_else' => 'red',
  );
  line qr/^\d+/(\w+)/ => \%protocols;

=cut

sub get {
  my ( $colour, $str ) = @_;
  if (ref($colour) eq 'ARRAY') {
    return get( shift @{$colour}, $str ) || '';
  } elsif (ref($colour) eq 'HASH') {
    return get( $colour->{$str}, $str ) || get( $colour->{_else} ) || '';
  } elsif (ref($colour) eq 'CODE') {
    return get( &$colour($str), $str ) || '';
  }
  return $colour;
}

=head2 colour( $begin, $end, $colour )

B<Modifies> the hash C<%colours>, in order to highlight the region
from C<$begin> to C<$end> in $colour.

=cut

sub colour {
  my ( $begin, $end, $colour ) = @_;
  return if !$colour;
  if ($color_stack) {
      push @{ $colours{$begin}->{push} }, $colour;
      push @{ $colours{$end}->{pop} }, $colour;
  } else {
      $colours{$begin} = $colour;
      $colours{$end}   = '';
  }
}

=head2 colourise

Uses the values in the hash C<%colours> to transform the string in
C<$_> to a colourised version of itself. This string is eventually
printed to stdout.

=cut

my $last = '';

sub colourise {
  ( my $process, local $_ ) = @_;
  return $_ if $_ eq "\n";

  %colours = ();
  &$process;

  if ($color_stack) {
    # This will break with overlapping regions
    my @parts = sort { $a <=> $b } keys %colours;

    if (@parts) {
      my @current_colors = ();
      my $reset = color("reset");
      my @string = ();
      push @string, substr($_, 0, $parts[0]) if $parts[0];

      # Build up the colorized string
      for my $p (0 .. $#parts) {
        my $i = $parts[$p];
        while ( $colours{$i}->{pop} and @{$colours{$i}->{pop}} ) {
          my $col = shift @{$colours{$i}->{pop}};
          my $c = 0;
          for my $c (0 .. $#current_colors) {
            if ($col eq $current_colors[$c]) {
              splice(@current_colors, $c, 1);
              last;
            }
          }
        }
        unshift @current_colors, reverse @{$colours{$i}->{push}} if $colours{$i}->{push};

        my $end = ($p == $#parts ? length($_) : $parts[$p+1]);
        if ($end > $i) {
          my $col = ($current_colors[0] || "");
          if ($col) {
            push @string, color($col);
          }
          push @string, substr($_, $i, $end - $i);
          if ($col) {
            push @string, $reset;
          }
        }
      }
      $_ = join("", @string);
    }
  } else {
    my @parts = sort { $b <=> $a } keys %colours;

    # Any colour that's /on_/ or /bold/ needs to be reset afterwards, so
    # the colours/boldness return to normal values.

    for my $i ( 0 .. $#parts ) {
      my ( $last, $part ) = @colours{ @parts[ $i - 1, $i ] };
      carp "Uninitialised value in colourise (try adding more arguments)"
        and next unless defined $part;

      if ( $i and ($part =~ m/bold/ and $last !~ m/bold/)
               or ($part =~ m/on_/  and $last !~ m/_on/ ) ) {
        $colours{ $parts[ $i - 1 ] } = "clear $last";
      }
    }

    # Actually apply the changes and update the string (backwards, as to
    # not overwrite previous changes)

    for my $i ( @parts ) {
      substr $_, $i, 0, color( $colours{$i} || 'reset' );
    }
  }

  %colours = ();  # just making sure
  return $_;
}

=head2 real_path

Returns the path to the original program that should be run - that is,
the one not in the scripts directory.

=cut

sub real_path {
  my @dirs  = PATH->Whence($file);
  my $index = firstidx { $_ eq $0 } @dirs;
  my $path  = $dirs[ $index + 1 ]
    or croak "Executable not in \$PATH: $file";

  return $path;
}

1;

__END__

=head1 AUTHOR

Benjamin Sago aka `cytzol' C<< <ben&cytzol,org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Benjamin Sago.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 2
#   fill-column: 70;
#   indent-tabs-mode: nil
# End:
# vi: set ts=2 sts=2 sw=2 tw=70 et
