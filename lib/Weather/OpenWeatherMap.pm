package Weather::OpenWeatherMap;
$Weather::OpenWeatherMap::VERSION = '0.001003';
use strictures 1;
use Carp;

use LWP::UserAgent;

use Types::Standard -all;


use Weather::OpenWeatherMap::Error;
use Weather::OpenWeatherMap::Request;
use Weather::OpenWeatherMap::Result;


use Moo; use MooX::late;

=pod

=for Pod::Coverage has_api_key

=cut

has api_key => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  predicate => 1,
  builder   => sub { '' },
);

has ua => (
  is        => 'ro',
  isa       => InstanceOf['LWP::UserAgent'],
  builder   => sub { LWP::UserAgent->new(timeout => 60) },
);


sub get_weather {
  my ($self, %args) = @_;

  my $location = $args{location};
  croak "Missing 'location =>' in query" unless $location;

  my $type = delete $args{forecast} ? 'Forecast' : 'Current';
  my $my_request = Weather::OpenWeatherMap::Request->new_for(
    $type => 
      (
        $self->has_api_key && length $self->api_key ?
          ( api_key => $self->api_key ) : ()
      ),
      %args
  );

  my $http_response = $self->ua->request( $my_request->http_request );

  unless ($http_response->is_success) {
    die Weather::OpenWeatherMap::Error->new(
      request => $my_request,
      source  => 'http',
      status  => $http_response->status_line,
    );
  }

  my $result = Weather::OpenWeatherMap::Result->new_for(
    $type =>
      request => $my_request,
      json    => $http_response->content
  );

  unless ($result->is_success) {
    die Weather::OpenWeatherMap::Error->new(
      request => $my_request,
      source  => 'api',
      status  => $result->error,
    )
  }

  $result
}


1;

=pod

=head1 NAME

Weather::OpenWeatherMap - Interface to the OpenWeatherMap API

=head1 SYNOPSIS

  use Weather::OpenWeatherMap;

  my $api_key = 'foo';

  my $wx = Weather::OpenWeatherMap->new(
    api_key => $api_key,
  );

  # Current conditions:
  my $current = $wx->get_weather(
    location => 'Manchester, NH',
  );
  my $tempf = $current->temp_f;
  my $wind  = $current->wind_speed_mph;
  # (see Weather::OpenWeatherMap::Result::Current)

  # Forecast conditions:
  my $forecast = $wx->get_weather(
    location => 'Manchester, NH',
    forecast => 1,
    days     => 3,
  );
  for my $day ($forecast->list) {
    my $date    = $day->dt->mdy;
    my $temp_lo = $day->temp_min_f,
    my $temp_hi = $day->temp_max_f,
    # (see Weather::OpenWeatherMap::Result::Forecast::Day)
  }
  # (see Weather::OpenWeatherMap::Result::Forecast)

=head1 DESCRIPTION

An object-oriented interface to retrieving weather conditions & forecasts from
B<OpenWeatherMap> (L<http://www.openweathermap.org/>) for a given city,
latitude/longitude, or OpenWeatherMap city code.

This module provides a simple blocking (L<LWP::UserAgent>) interface to
weather retrieval; if you have an event loop handy, the included
L<Weather::OpenWeatherMap::Request> & L<Weather::OpenWeatherMap::Result>
classes can be used to create appropriate L<HTTP::Request> instances and parse
responses from non-blocking HTTP clients.

=head2 ATTRIBUTES

=head3 api_key

Your L<OpenWeatherMap|http://www.openweathermap.org/> API key.

(See L<http://www.openweathermap.org/api> to register for free.)

=head3 ua

The L<LWP::UserAgent> instance used to issue HTTP requests; can be used to
control LWP options:

  my $wx = Weather::OpenWeatherMap->new(
    api_key => $my_api_key,
    ua => LWP::UserAgent->new(%lwp_opts),  
  );

=head2 METHODS

=head3 get_weather

  $wx->get_weather(
    # 'location =>' is mandatory.
    #  These are all valid location strings:
    #  By name:
    #   'Manchester, NH'
    #   'London, UK'
    #  By OpenWeatherMap city code:
    #   5089178
    #  By latitude/longitude:
    #   'lat 42, long -71'
    location => 'Manchester, NH',

    # Set 'forecast => 1' to get the forecast,
    # omit or set to false for current weather:
    forecast => 1,

    # If 'forecast' is true, you can specify the number of days to fetch
    # (up to 14):
    days => 3,

    # Optional tag for identifying the response to this request:
    tag  => 'foo',
  );

Request a weather report for the given C<< location => >>.

The location can be a 'City, State' or 'City, Country' string, an
L<OpenWeatherMap|http://www.openweathermap.org/> city code, or a 'lat X, long
Y' string.

Requests the current weather by default (see
L<Weather::OpenWeatherMap::Request::Current>).

If passed C<< forecast => 1 >>, requests a weather forecast (see
L<Weather::OpenWeatherMap::Request::Forecast>), in which case C<< days
=> $count >> can be specified (up to 14).

Any extra arguments are passed to the constructor for the appropriate Request
subclass; see L<Weather::OpenWeatherMap::Request>.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

# vim: ts=2 sw=2 et sts=2 ft=perl
