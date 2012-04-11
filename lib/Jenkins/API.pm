package Jenkins::API;

use Moose;

=head1 NAME

Jenkins::API - The great new Jenkins::API!

=head1 VERSION

Version 0.01

=head1 METHODS

=cut

our $VERSION = '0.01';

has '_client' => (is => 'ro', default => sub {
    require REST::Client;
    REST::Client->new();
});
has base_url => (is => 'ro', isa => 'Str', default => 'http://moe:8080');

=head1 SYNOPSIS

This is a wrapper around the Jenkins API.

    use Jenkins::API;

    my $jenkins = Jenkins::API->new({ base_url => 'http://jenkins:8080' });
    my $success = $jenkins->create_job($config_xml);
    ...

=head2 create_job

    my $success = $api->create_job($config_xml);

=cut

sub create_job
{
    my ($self, $job_config) = @_;

    $self->_client->POST($self->base_url . '/createItem', $job_config);
    return $self->_client->responseCode() eq '200';
}

=head2 create_job_simple

    $self->create_job_simple(
        { 
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

=cut

sub create_job_simple
{
    my ($self, $args) = @_;

    my $schema = XML::Compile::Schema->new('compile.xsd');
    my $doc = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $writer = $schema->compile(WRITER => 'project');
    my $xml = $writer->($doc, $args);
    $doc->setDocumentElement($xml);
    $self->create_job($doc->toString());
}

=head1 AUTHOR

Colin Newell, C<< <colin.newell at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jenkins-api at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Jenkins-API>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Jenkins::API


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Jenkins-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Jenkins-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Jenkins-API>

=item * Search CPAN

L<http://search.cpan.org/dist/Jenkins-API/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Colin Newell.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Jenkins::API

