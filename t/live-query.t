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

my $status = $api->current_status;
ok grep { $_ eq 'Test-Project' } map { $_->{name} } @{$status->{jobs}};
note 'This is the current status returned by the API';
explain($status);

note 'This is a more refined query of the API';
$status = $api->current_status({ tree => 'jobs[name,color]' });
explain $status;
ok grep { $_ eq 'Test-Project' } map { $_->{name} } @{$status->{jobs}};

$status = $api->current_status({ depth => 1 });
note 'With depth => 1';
explain $status;

my $build_status = $api->build_queue;
note 'Build queue';
explain $build_status;
$build_status = $api->build_queue({ depth => 1 });;
note 'With depth => 1';
explain $build_status;

done_testing;
