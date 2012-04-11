use inc::Module::Install;

name     'Jenkins-API';
all_from 'lib/Jenkins/API.pm';
author   q{Colin Newell <colin.newell@gmail.com>};
license  'perl';

requires 'REST::Client';
requires 'XML::Compile';

build_requires 'Test::More';

auto_install;

WriteAll;

