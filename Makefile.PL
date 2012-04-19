use inc::Module::Install;

name     'Jenkins-API';
all_from 'lib/Jenkins/API.pm';
author   q{Colin Newell <colin.newell@gmail.com>};
license  'perl';

requires 'REST::Client';
requires 'URI::Encode';
requires 'File::ShareDir';
requires 'XML::Compile';
requires 'XML::LibXML';

build_requires 'Test::Most';

auto_install;

WriteAll;

