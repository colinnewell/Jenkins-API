package Jenkins::API;

use Moose;
use Jenkins::API::ConfigBuilder;
use JSON;

=head1 NAME

Jenkins::API - A wrapper around the Jenkins API

=head1 VERSION

Version 0.01

=head1 METHODS

=cut

our $VERSION = '0.01';

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

=head2 create_job

Takes the project name and the xml for a config file and gets
Jenkins to create the job.

    my $success = $api->create_job($project_name, $config_xml);

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

sub current_status
{
    my $self = shift;

    my $uri = URI->new($self->base_url);
    $uri->path_segments('api','json');
    $self->_client->GET($uri->as_string);
    die 'Invalid response' unless $self->_client->responseCode eq '200';
    # NOTE: my server returns UTF8, if this turns out to be a broken
    # assumption read the Content-Type header.
    my $data = JSON->new->utf8->decode($self->_client->responseContent());
    return $data;
}

=head2 create_job_simple

Creates a job using a hash of information.  This builds the XML
to pass to Jenkins for you by using the L<Jenkins::API::ConfigBuilder>.
See that for details of the hash.  Currently this module is very new
and the exact details of the hash are very likely to change.

    $self->create_job_simple($project_name, $config_hash);

=cut

sub create_job_simple
{
    my ($self, $name, $args) = @_;

    my $cb = Jenkins::API::ConfigBuilder->new();
    my $xml = $cb->to_xml($args);
    return $self->create_job($name, $xml);
}

=head1 AUTHOR

Colin Newell, C<< <colin.newell at gmail.com> >>

=head1 BUGS

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


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Colin Newell.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Jenkins::API

