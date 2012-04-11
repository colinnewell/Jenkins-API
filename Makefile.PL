use inc::Module::Install;

name     'Jenkins-API';
all_from 'lib/Jenkins/API.pm';
author   q{Colin Newell <colin.newell@gmail.com>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

