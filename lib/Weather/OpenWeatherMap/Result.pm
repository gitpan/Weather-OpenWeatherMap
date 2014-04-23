package Weather::OpenWeatherMap::Result;
$Weather::OpenWeatherMap::Result::VERSION = '0.001002';
use Carp;
use strictures 1;

use JSON::Tiny;

use Module::Runtime 'use_module';
use List::Objects::Types -all;
use Types::Standard      -all;


use Moo; use MooX::late;

sub new_for {
  my ($class, $type) = splice @_, 0, 2;
  confess "Expected a subclass type" unless $type;
  my $subclass = $class .'::'. ucfirst($type);
  use_module($subclass)->new(@_)
}


has request => (
  required  => 1,
  is        => 'ro',
  isa       => InstanceOf['Weather::OpenWeatherMap::Request'],
);

has json => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
);

has data => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  builder   => sub {
    my ($self) = @_;
    JSON::Tiny->new->decode( $self->json )
  },
);

has response_code => (
  lazy      => 1,
  is        => 'ro',
  isa       => Maybe[Int],
  builder   => sub {
    my ($self) = @_;
    $self->data->{cod}
  },
);


has is_success => (
  lazy      => 1,
  is        => 'ro',
  isa       => Bool,
  builder   => sub {
    my ($self) = @_;
    ($self->response_code // '') eq '200'
  },
);

has error => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  builder   => sub {
    my ($self) = @_;
    return '' if $self->is_success;
    my $data = $self->data;
    my $msg = $data->{message} || 'Unknown error from backend';
    # there's only so much I can take ->
    $msg = 'Not found' if $msg =~ /Not found city/;
    $msg
  },
);

1;

=pod

=head1 NAME

Weather::OpenWeatherMap::Result - Weather lookup result superclass

=head1 SYNOPSIS

  # Normally retrieved via Weather::OpenWeatherMap

=head1 DESCRIPTION

This is the parent class for L<Weather::OpenWeatherMap> weather results.

See also:

L<Weather::OpenWeatherMap::Result::Current>

L<Weather::OpenWeatherMap::Result::Forecast>

=head2 ATTRIBUTES

=head3 data

This is the decoded hash from the attached L</json>. 

Subclasses provide more convenient accessors for retrieving desired
information.

=head3 error

The error message received from the OpenWeatherMap backend (or the empty
string if there was no error).

See also: L</is_success>, L</response_code>

=head3 is_success

Returns boolean true if the OpenWeatherMap backend returned a successful
response.

See also: L</error>, L</response_code>

=head3 json

The raw JSON this Result was created with.

=head3 response_code

The response code from OpenWeatherMap.

See also: L</is_success>, L</error>

=head3 request

The original request that was attached to this result.

=head2 METHODS

=head3 new_for

Factory method; returns a new object belonging to the appropriate subclass:

  my $result = Weather::OpenWeatherMap::Result->new_for(
    Forecast =>
      request => $orig_request,
      json    => $raw_json,
  );

=head1 SEE ALSO

L<http://www.openweathermap.org>

L<Weather::OpenWeatherMap>

L<Weather::OpenWeatherMap::Result::Current>

L<Weather::OpenWeatherMap::Result::Forecast>

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

Licensed under the same terms as perl.

=cut
