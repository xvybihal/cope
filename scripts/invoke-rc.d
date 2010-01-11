#!/usr/bin/env perl
use App::Cope;

sub process {
	# default color!
	line qr{(.+)} => 'cyan';

	# highlight action
	line qr{(Stopping)} => 'red';
	line qr{(Restarting)} => 'yellow bold';
	line qr{(Starting)} => 'green bold';

	# the rest
	# TODO: clean this up
	line qr{Stopping (.+)} => 'cyan';
	line qr{Restarting (.+)} => 'cyan';
	line qr{Starting (.+)} => 'cyan';

	# mark errors!
	line qr{(failed.+)} => 'red bold';
}

run( \&process, real_path, @ARGV );
