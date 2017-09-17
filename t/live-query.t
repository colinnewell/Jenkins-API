use Test2::V0;

use Test2::Require::EnvVar 'LIVE_TEST_JENKINS_URL';
# Set LIVE_TEST_JENKINS_URL if you want to run these tests against a live jenkins server.
# Set LIVE_TEST_JENKINS_API_KEY and LIVE_TEST_JENKINS_API_PASS if your server requires authentication.
use Test2::Plugin::BailOnFail;
use Test2::Tools::Explain;

use Jenkins::API;
my $url = $ENV{LIVE_TEST_JENKINS_URL};
my $apiKey = $ENV{LIVE_TEST_JENKINS_API_KEY};
my $apiPass = $ENV{LIVE_TEST_JENKINS_API_PASS};

my $api = Jenkins::API->new(base_url => $url,
							api_key => $apiKey,
							api_pass => $apiPass);

my $v = $api->check_jenkins_url;
ok $v, 'Jenkins running on ' . $url;
note explain $v;

my $status = $api->current_status;
ok ((grep { $_ eq 'Test-Project' } map { $_->{name} } @{$status->{jobs}}),
    'Ensure we found the Test-Project');
note 'This is the current status returned by the API';
note explain($status);

note 'This is a more refined query of the API';
$status = $api->current_status({ extra_params => { tree => 'jobs[name,color]' }});
note explain $status;
ok grep { $_ eq 'Test-Project' } map { $_->{name} } @{$status->{jobs}};

$status = $api->current_status({ path_parts => [qw/job Test-Project/], extra_params => { depth => 1 }});
note 'Querying job Test-Project with depth => 1';
note explain $status;

my $build_status = $api->build_queue;
note 'Build queue';
note explain $build_status;
$build_status = $api->build_queue({ extra_params => { depth => 1 }});;
note 'With depth => 1';
note explain $build_status;

my $statistics = $api->load_statistics;
is $api->response_code, '200';
ok $api->response_content;
note explain $api->project_config('Test-Project');

my $job_info = $api->get_job_details('Test-Project');
note 'get_job_details';
note explain $job_info;

my $job_info2 = $api->get_job_details('Test-Project', { extra_params => { tree => 'healthReport' } });
note explain $job_info2;

note 'Load statistics';
note explain $statistics;


my $view = $api->view_status('Test');
note explain $view;
my $view_list = $api->current_status({ extra_params => { tree => 'views[name]' }});
note explain $view_list;
my @views = grep { $_ ne 'All' } map { $_->{name} } @{$view_list->{views}};
for my $view (@views)
{
    my $view_jobs = $api->view_status($view, { extra_params => { tree => 'jobs[name,color]' }});
    note explain $view_jobs;
}

my $response = $api->general_call(
    ['job', 'Test', 'api', 'json'], 
    {
        method => 'GET',
        extra_params => { tree => 'color,description' },
        decode_json => 1,
        expected_response_code => 200,
    });
note 'General call';
note explain $response;

done_testing;
