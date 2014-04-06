use inc::Module::Install;

name     'Jenkins-API';
all_from 'lib/Jenkins/API.pm';
author   q{Colin Newell <colin.newell@gmail.com>};
license  'perl';

requires 'REST::Client';
requires 'URI';
requires 'File::ShareDir';
requires 'JSON';
requires 'Moose';
requires 'MIME::Base64';

build_requires 'Test::Most';

resources(
        'license'    => 'http://dev.perl.org/licenses/',
        'homepage'   => 'https://github.com/colinnewell/Jenkins-API',
        'repository' => 'https://github.com/colinnewell/Jenkins-API',
        'bugtracker'  => 'https://github.com/colinnewell/Jenkins-API/issues',
);



auto_install;

WriteAll;

