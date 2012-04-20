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

ok $api->create_job_simple('Test-Project', 
        { 
          actions => {},
          properties => {},
          description => "Test Project",
          keepDependencies => "false",
          scm =>
          { 
            configVersion => 2,
            userRemoteConfigs =>
            { 
              'hudson.plugins.git.UserRemoteConfig' =>
              { 
                name => "",
                refspec => {},
                url => "git://github.com/colinnewell/Jenkins-API.git",
              }, 
            },
            branches => { 'hudson.plugins.git.BranchSpec' => { name => "master", }, },
            disableSubmodules => "false",
            recursiveSubmodules => "false",
            doGenerateSubmoduleConfigurations => "false",
            authorOrCommitter => "false",
            clean => "false",
            wipeOutWorkspace => "false",
            pruneBranches => "false",
            remotePoll => "false",
            buildChooser =>
            { class => "hudson.plugins.git.util.DefaultBuildChooser", },
            gitTool => "Default",
            submoduleCfg => { class => "list", },
            relativeTargetDir => {},
            reference => {},
            excludedRegions => {},
            excludedUsers => {},
            gitConfigName => {},
            gitConfigEmail => {},
            skipTag => "false",
            scmName => {},
            class => "hudson.plugins.git.GitSCM", },
          canRoam => "true",
          disabled => "false",
          blockBuildWhenDownstreamBuilding => "false",
          blockBuildWhenUpstreamBuilding => "false",
          triggers =>
          { 
            'hudson.triggers.SCMTrigger' =>
            { 
              spec => "*/5 * * * *", },
            class => "vector", },
          concurrentBuild => "false",
          builders =>
          { 
            'hudson.tasks.Shell' =>
            [ 
            { command => "eval `/opt/perl5/bin/perl -Mlocal::lib=~/perl5`", }, 
            { command => "/opt/perl5/bin/cpanm --installdeps . -l ~/perl5", }, 
            { command => "/opt/perl5/bin/prove -I /var/lib/jenkins/perl5/lib/perl5/i686-linux -I /var/lib/jenkins/perl5/lib/perl5 --timer --formatter=TAP::Formatter::JUnit -l t > \${JOB_NAME}-\${BUILD_NUMBER}-junit.xml", }, 
            ], },
          publishers =>
          { 
            'hudson.tasks.junit.JUnitResultArchiver' =>
            { 
              testResults => "*junit.xml",
              keepLongStdio => "false",
              testDataPublishers => {}, },
            'hudson.tasks.Mailer' =>
            { 
              recipients => "colin.newell",
              dontNotifyEveryUnstableBuild => "false",
              sendToIndividuals => "false", }, },
          buildWrappers => {}, 
        }
);
$api->trigger_build('Test-Project');

done_testing;

