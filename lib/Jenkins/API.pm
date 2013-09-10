package Jenkins::API;

use Moose;
use JSON;

=head1 NAME

Jenkins::API - A wrapper around the Jenkins API

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

has '_client' => (is => 'ro', default => sub {
    require REST::Client;
    REST::Client->new();
});
has base_url => (is => 'ro', isa => 'Str', required => 1);

=head1 SYNOPSIS

This is a wrapper around the Jenkins API.  

    use Jenkins::API;

    my $jenkins = Jenkins::API->new({ base_url => 'http://jenkins:8080' });
    my $status = $jenkins->current_status();
    my @not_succeeded = grep { $_->{color} ne 'blue' } @{$status->{jobs}};
    # {
    #   'color' => 'red',
    #   'name' => 'Test-Project',
    #   'url' => 'http://jenkins:8080/job/Test-Project/',
    # }

    my $success = $jenkins->create_job($project_name, $config_xml);
    ...

=head1 METHODS

=head2 check_jenkins_url

Checks the url provided to the api has a Jenkins server running on it.
It returns the version number of the Jenkins server if it is running.

    $jenkins->check_jenkins_url;
    # 1.460

=head2 current_status

Returns the current status of the server as returned by the API.  This 
is a hash containing a fairly comprehensive list of what's going on.

    $jenkins->current_status();
    # {
    #   'assignedLabels' => [
    #     {}
    #   ],
    #   'description' => undef,
    #   'jobs' => [
    #     {
    #       'color' => 'blue',
    #       'name' => 'Jenkins-API',
    #       'url' => 'http://jenkins:8080/job/Jenkins-API/'
    #     },
    #   'mode' => 'NORMAL',
    #   'nodeDescription' => 'the master Jenkins node',
    #   'nodeName' => '',
    #   'numExecutors' => 2,
    #   'overallLoad' => {},
    #   'primaryView' => {
    #     'name' => 'All',
    #     'url' => 'http://jenkins:8080/'
    #   },
    #   'quietingDown' => bless( do{\(my $o = 0)}, 'JSON::XS::Boolean' ),
    #   'slaveAgentPort' => 0,
    #   'useCrumbs' => $VAR1->{'quietingDown'},
    #   'useSecurity' => $VAR1->{'quietingDown'},
    #   'views' => [
    #     {
    #       'name' => 'All',
    #       'url' => 'http://jenkins:8080/'
    #     }
    #   ]
    # }

It is also possible to pass two parameters to the query to refine or 
expand the data you get back.  The tree parameter allows you to select
specific elements. The example from the Jenkins documentation , C<< tree=> 'jobs[name],views[name,jobs[name]]' >> demonstrates the syntax nicely.

The other parameter you can pass is depth, by default it's 0, if you set
it higher it dumps a ton of data.

    $jenkins->current_status({ extra_params => { tree => 'jobs[name,color]' }});;
    # {
    #   'jobs' => [
    #     {
    #       'color' => 'blue',
    #       'name' => 'Jenkins-API',
    #     },
    #   ]
    # }

    $jenkins->current_status({ extra_params => { depth => 1 }});
    # returns everything and the kitchen sink.

It is also possible to only look at a subset of the data.  Most urls
you can see on the website in Jenkins can be accessed.  If you have a 
job named Test-Project for example with the url C</job/Test-Project> you
can specify the C<< path_parts => ['job', 'Test-Project'] >> to look at the
data for that job alone.

    $jenkins->current_status({ 
        path_parts => [qw/job Test-Project/],
        extra_params => { depth => 1 },
    });
    # just returns the data relating to job Test-Project.
    # returning it in detail.

The method will die saying 'Invalid response' if the server doesn't
respond as it expects, or die with a JSON decoding error if the JSON
parsing fails.

=head2 trigger_build

Trigger a build,

    $success = $jenkins->trigger_build('Test-Project');

If you need to specify a token you can pass that like this,

    $jenkins->trigger_build('Test-Project', { token => $token });

Note that the success response is simply to indicate that the build
has been scheduled, not that the build has succeeded.

=head2 trigger_build_with_parameters

Trigger a build with parameters,

    $success = $jenkins->trigger_build_with_parameters('Test-Project', { Parameter => 'Value' } );

The method behaves the same way as L<trigger_build>.

=head2 build_queue

This returns the items in the build queue.

    $jenkins->build_queue();

This allows the same C<extra_params> as the L</current_status> call.  The
depth and tree parameters work in the same way.  See the Jenkins
api documentation for more details.

The method will die saying 'Invalid response' if the server doesn't
respond as it expects, or die with a JSON decoding error if the JSON
parsing fails.

=head2 load_statistics

This returns the load statistics for the server.

    $jenkins->load_statistics();
    # {
    #   'busyExecutors' => {},
    #   'queueLength' => {},
    #   'totalExecutors' => {},
    #   'totalQueueLength' => {}
    # }

This also allows the same C<extra_params> as the L</current_status> call.  The
depth and tree parameters work in the same way.  See the Jenkins
api documentation for more details.

The method will die saying 'Invalid response' if the server doesn't
respond as it expects, or die with a JSON decoding error if the JSON
parsing fails.

=head2 create_job

Takes the project name and the xml for a config file and gets
Jenkins to create the job.

    my $success = $api->create_job($project_name, $config_xml);

=head2 project_config

This method returns the configuration for the project in xml.

    my $config = $api->project_config($project_name);

=head2 set_project_config

This method allows you to set the configuration for the project using xml.

    my $success = $api->set_project_config($project_name, $config);

=head2 delete_project

Delete the project from Jenkins.

    my $success = $api->delete_project($project_name);

=cut

sub create_job
{
    my ($self, $name, $job_config) = @_;

    my $uri = URI->new($self->base_url);
    $uri->path_segments('createItem');
    $uri->query_form( name => $name );
    # curl -XPOST http://moe:8080/createItem?name=test -d@config.xml -v -H Content-Type:text/xml
    $self->_client->POST($uri->as_string, $job_config, { 'Content-Type' => 'text/xml' });
    return $self->_client->responseCode() eq '200';
}

sub delete_project
{
    my ($self, $name) = @_;

    my $uri = URI->new($self->base_url);
    $uri->path_segments('job', $name, 'doDelete');
    $self->_client->POST($uri->as_string, undef, { 'Content-Type' => 'text/xml' });
    return $self->_client->responseCode() eq '302';
}

sub trigger_build
{
  my $self = shift;
  return $self->_trigger_build('build', @_);
}

sub trigger_build_with_parameters
{
  my $self = shift;
  return $self->_trigger_build('buildWithParameters', @_);
}

sub _trigger_build
{
    my $self = shift;
    my $build_url = shift;
    my $job = shift;
    my $extra_params = shift;

    my $uri = URI->new($self->base_url);
    $uri->path_segments('job', $job, $build_url);
    $uri->query_form($extra_params) if $extra_params;
    $self->_client->GET($uri->as_string);
    return $self->_client->responseCode eq '302';
}

sub project_config
{
    my $self = shift;
    my $job = shift;
    my $extra_params = shift;

    my $uri = URI->new($self->base_url);
    $uri->path_segments('job', $job, 'config.xml');
    $uri->query_form($extra_params) if $extra_params;
    $self->_client->GET($uri->as_string);
    return $self->_client->responseContent;
}

sub set_project_config
{
    my $self = shift;
    my $job = shift;
    my $config = shift;

    my $uri = URI->new($self->base_url);
    $uri->path_segments('job', $job, 'config.xml');
    $self->_client->POST($uri->as_string, $config, { 'Content-Type' => 'text/xml' });
    return $self->_client->responseCode() eq '200';
}

sub check_jenkins_url
{
    my $self = shift;
    $self->_client->GET($self->base_url);
    return $self->_client->responseCode() eq '200'
        && $self->_client->responseHeader('X-Jenkins');
}

sub build_queue
{
    my $self = shift;
    return $self->_json_api(['queue', 'api','json'], @_);
}

sub load_statistics
{
    my $self = shift;
    return $self->_json_api(['overallLoad', 'api','json'], @_);
}

sub current_status
{
    my $self = shift;
    return $self->_json_api(['api','json'], @_);
}

sub _json_api
{
    my $self = shift;
    my $uri_parts = shift;
    my $args = shift;
    my $extra_params = $args->{extra_params};
    my $bits = $args->{path_parts} || [];

    my $uri = URI->new($self->base_url);
    $uri->path_segments(@$bits, @$uri_parts);
    $uri->query_form($extra_params) if $extra_params;
    $self->_client->GET($uri->as_string);
    die 'Invalid response' unless $self->_client->responseCode eq '200';
    # NOTE: my server returns UTF8, if this turns out to be a broken
    # assumption read the Content-Type header.
    my $data = JSON->new->utf8->decode($self->_client->responseContent());
    return $data;
}

=head2 response_code

This method returns the HTTP response code from our last request to 
the Jenkins server.  This may be useful when an error occurred.

=cut

sub response_code
{
    my $self = shift;
    return $self->_client->responseCode;
}

=head2 response_content

This method returns the content of the HTTP response from our 
last request to the Jenkins server.  This may be useful when 
an error occurrs.

=cut

sub response_content
{
    my $self = shift;
    return $self->_client->responseContent;
}


=head1 AUTHOR

Colin Newell, C<< <colin.newell at gmail.com> >>

=head1 BUGS

The API wrapper doesn't deal with jenkins installations not running from
the root path.  I don't actually know if that's an install option, but
the internal url building just doesn't deal with that situation properly.
If you want that fixing a patch is welcome.

Please report any bugs or feature requests to through the web interface 
at L<https://github.com/colinnewell/Jenkins-API/issues/new>.  I will 
be notified, and then you'll automatically be notified of progress 
on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Jenkins::API


You can also look for information at:

=over 4

=item * github issue list

L<https://github.com/colinnewell/Jenkins-API/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Jenkins-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Jenkins-API>

=item * Search CPAN

L<http://search.cpan.org/dist/Jenkins-API/>

=back

=head1 SEE ALSO

=over 4

=item * Jenkins CI server

L<http://jenkins-ci.org/>

=item * Net::Jenkins

An alternative to this library.

L<https://metacpan.org/module/Net::Jenkins>

=item * Task::Jenkins

Libraries to help testing modules on a Jenkins server.

L<https://metacpan.org/module/Task::Jenkins>

=back

=head1 ACKNOWLEDGEMENTS

Birmingham Perl Mongers for feedback before I released this to CPAN.

With thanks to Nick Hu for adding the trigger_build_with_parameters method.

=head1 LICENSE AND COPYRIGHT

Copyright 2012-2013 Colin Newell.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Jenkins::API

