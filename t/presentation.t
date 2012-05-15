use Test::Most;

BEGIN {
    unless ($ENV{LIVE_TEST_JENKINS_URL})
    {
        plan skip_all => 'Set LIVE_TEST_JENKINS_URL if you want to run these tests against a live jenkins server';
    }
}
use Jenkins::API;
my $url = $ENV{LIVE_TEST_JENKINS_URL};
my $api = Jenkins::API->new(base_url => $url);

my $v = $api->check_jenkins_url;
ok $v, 'Jenkins running on ' . $url;
note '$api->check_jenkins_url;';
explain $v;

my $status = $api->current_status;
note '$api->current_status;';
explain($status);

done_testing;
