use Test::Most;

use Jenkins::API::ConfigBuilder;

my $cb = Jenkins::API::ConfigBuilder->new();
my $xml = $cb->to_xml(
        { 
          actions => {},
          properties => {},
          description => "Project Description",
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
                url => "ssh://git/....", 
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
is $xml, '<?xml version="1.0" encoding="UTF-8"?>
<project><actions/><description>Project Description</description><keepDependencies>false</keepDependencies><properties/><scm class="hudson.plugins.git.GitSCM"><configVersion>2</configVersion><userRemoteConfigs><hudson.plugins.git.UserRemoteConfig><name></name><refspec/><url>ssh://git/....</url></hudson.plugins.git.UserRemoteConfig></userRemoteConfigs><branches><hudson.plugins.git.BranchSpec><name>master</name></hudson.plugins.git.BranchSpec></branches><disableSubmodules>false</disableSubmodules><recursiveSubmodules>false</recursiveSubmodules><doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations><authorOrCommitter>false</authorOrCommitter><clean>false</clean><wipeOutWorkspace>false</wipeOutWorkspace><pruneBranches>false</pruneBranches><remotePoll>false</remotePoll><buildChooser class="hudson.plugins.git.util.DefaultBuildChooser"/><gitTool>Default</gitTool><submoduleCfg class="list"/><relativeTargetDir/><reference/><excludedRegions/><excludedUsers/><gitConfigName/><gitConfigEmail/><skipTag>false</skipTag><scmName/></scm><canRoam>true</canRoam><disabled>false</disabled><blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding><blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding><triggers class="vector"><hudson.triggers.SCMTrigger><spec>*/5 * * * *</spec></hudson.triggers.SCMTrigger></triggers><concurrentBuild>false</concurrentBuild><builders><hudson.tasks.Shell><command>eval `/opt/perl5/bin/perl -Mlocal::lib=~/perl5`</command></hudson.tasks.Shell><hudson.tasks.Shell><command>/opt/perl5/bin/cpanm --installdeps . -l ~/perl5</command></hudson.tasks.Shell><hudson.tasks.Shell><command>/opt/perl5/bin/prove -I /var/lib/jenkins/perl5/lib/perl5/i686-linux -I /var/lib/jenkins/perl5/lib/perl5 --timer --formatter=TAP::Formatter::JUnit -l t &gt; ${JOB_NAME}-${BUILD_NUMBER}-junit.xml</command></hudson.tasks.Shell></builders><publishers><hudson.tasks.junit.JUnitResultArchiver><testResults>*junit.xml</testResults><keepLongStdio>false</keepLongStdio><testDataPublishers/></hudson.tasks.junit.JUnitResultArchiver><hudson.tasks.Mailer><recipients>colin.newell</recipients><dontNotifyEveryUnstableBuild>false</dontNotifyEveryUnstableBuild><sendToIndividuals>false</sendToIndividuals></hudson.tasks.Mailer></publishers><buildWrappers/></project>
';
ok $cb->default_project;

done_testing;
