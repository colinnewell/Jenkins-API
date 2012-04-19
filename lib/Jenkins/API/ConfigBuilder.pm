package Jenkins::API::ConfigBuilder;

=head1 NAME

Jenkins::API::ConfigBuilder

=head1 DESCRIPTION

This is a module for creating the XML for the config files for a 
project in Jenkins.

I<This modules interface is very likely to change. I've currently
implemented the bare minimum to get the API working but I'm
of the opinion it currently sucks.  How to fix that I'm not sure
yet.  The first order of business is to tidy up the XSD and get
the XML generation solid.  Once that's done I'll understand what
I can build and hopefully build a decent API for the Builder.>

=head1 METHODS

=head2 to_xml

This is a simple method that takes a hash and produces xml for it
using the internal XSD for the XML file.  It will choke if any
required elements are missing.

I<This is still very much under development.  The XSD used to produce
the XML probably needs a lot of refinement.  It was generated from
a single Jenkins config file and is therefore likely to only contain
the options I had selected.  It may also be the case that I can make
a lot of the options optional, in which case I should be able to 
reduce the complexity of the hash required.>  

I<With luck I shouldn't need to dramatically change the structure of the 
hash, but I will probably need to add possible elements. I will quite 
possibly tweak whether certain elements are required or not.>

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
                  recipients => "user",
                  dontNotifyEveryUnstableBuild => "false",
                  sendToIndividuals => "false", }, },
              buildWrappers => {}, 
            }
    );

=head2 default_project

Returns a hash containing the default information it needs.  It may
be easiest to get this hash and then amend the details you are 
interested in.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Colin Newell.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


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
    # FIXME: can we product the configs in a more human 
    # readable form?
    my $doc = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $writer = $schema->compile(WRITER => 'project');
    my $xml = $writer->($doc, $hash);
    $doc->setDocumentElement($xml);
    return $doc->toString();
}

sub default_project
{
    my $self = shift;
    return
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
              recipients => "user",
              dontNotifyEveryUnstableBuild => "false",
              sendToIndividuals => "false", }, },
          buildWrappers => {}, 
        };
}

1;
