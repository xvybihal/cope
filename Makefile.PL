use inc::Module::Install;

# metadata
name 'App-Cope';
all_from 'lib/App/Cope.pm';

# use 5.10 for given/when construct
perl_version '5.010';

# requirements
requires 'Env::Path';
requires 'File::ShareDir';
requires 'IO::Handle';
requires 'IO::Pty';
requires 'IO::Stty';
requires 'List::MoreUtils';
requires 'Regexp::Common';
requires 'Term::ANSIColor';
requires 'Regexp::IPv6';

# testing
test_requires 'Test::More';

# install the scripts
install_share 'share';
install_script 'bin/cope_path.pl';

# go go go!
auto_install;
WriteAll;
