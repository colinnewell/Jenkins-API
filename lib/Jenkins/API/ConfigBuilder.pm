package Jenkins::API::ConfigBuilder;

=head1 NAME

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
=cut

use Moose;
use XML::Compile::Schema;
use XML::LibXML;
use File::ShareDir;

sub to_xml
{
    my $self = shift;
    my $hash = shift;
    my $config_spec = File::ShareDir::module_file(__PACKAGE__, 'config.xsd');
    my $schema = XML::Compile::Schema->new($config_spec);
    my $doc = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $writer = $schema->compile(WRITER => 'project');
    my $xml = $writer->($doc, $hash);
    $doc->setDocumentElement($xml);
    return $doc->toString();
}

1;
