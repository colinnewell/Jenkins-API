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

resources(
        'license',    => 'http://dev.perl.org/licenses/',
        'homepage',   => 'https://github.com/colinnewell/Jenkins-API',
        'repository', => {
            web => 'https://github.com/colinnewell/Jenkins-API',
            url => 'git://github.com/colinnewell/Jenkins-API.git',
            type => 'git',
        },
        bugtracker  => {
            web => 'https://github.com/colinnewell/Jenkins-API/issues',
        }
);



auto_install;

WriteAll;

