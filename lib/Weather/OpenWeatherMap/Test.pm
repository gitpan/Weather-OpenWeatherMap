package Weather::OpenWeatherMap::Test;
$Weather::OpenWeatherMap::Test::VERSION = '0.001002';
=pod

=for Pod::Coverage .*

=cut

use v5.10;
use strictures 1;
use Carp;
use JSON::Tiny;

use parent 'Exporter::Tiny';
our @EXPORT = our @EXPORT_OK = qw/
  get_test_data
  mock_http_ua
/;

our $JSON_Current;
our $JSON_Forecast;
{
  my $perlstr = do {; local $/; <DATA> };
  local $@;
  my $ret = eval $perlstr;
  die $@ if $@;
  die "Expected evalled DATA to return ARRAY but got $ret"
    unless ref $ret eq 'ARRAY';
  ($JSON_Current, $JSON_Forecast) = @$ret;
}


sub get_test_data {
  my $type = lc (shift || return);
  for ($type) {
    return $JSON_Current
      if $type eq 'current';

    return $JSON_Forecast
      if $type eq '3day'
      or $type eq 'forecast';
  }

  confess "Unknown type $type"
}

{ package
    Weather::OpenWeatherMap::Test::MockUA;
  use strict; use warnings FATAL => 'all';
  require HTTP::Response;
  use parent 'LWP::UserAgent';
  sub requested_count { my ($self) = @_; $self->{'__requested'} }
  sub request {
    my ($self, $http_request) = @_;
    my $url = $http_request->uri;
    $self->{'__requested'} ? 
      ++$self->{'__requested'} : ($self->{'__requested'} = 1);
    return $url =~ /forecast/ ?
      HTTP::Response->new(
        200 => undef => [] => $self->{forecast_json},
      )
      : HTTP::Response->new(
        200 => undef => [] => $self->{current_json},
      )
  }
}

sub mock_http_ua {
  return bless +{
    forecast_json => get_test_data('forecast'),
    current_json  => get_test_data('current'),
  }, 'Weather::OpenWeatherMap::Test::MockUA'
}


__DATA__
my $current = <<'EOCURRENT';
{
   "rain" : {
      "1h" : 0.25
   },
   "base" : "cmc stations",
   "sys" : {
      "country" : "United States of America",
      "sunrise" : 1397728770,
      "sunset" : 1397777462,
      "message" : 0.005
   },
   "dt" : 1397768668,
   "name" : "Manchester",
   "cod" : 200,
   "main" : {
      "pressure" : 1040,
      "temp" : 41.07,
      "temp_min" : 37.99,
      "temp_max" : 45,
      "humidity" : 49
   },
   "wind" : {
      "gust" : 6.17,
      "speed" : 2.22,
      "deg" : 59
   },
   "weather" : [
      {
         "icon" : "10d",
         "id" : 500,
         "description" : "light rain",
         "main" : "Rain"
      }
   ],
   "coord" : {
      "lat" : 42.99,
      "lon" : -71.46
   },
   "clouds" : {
      "all" : 8
   },
   "id" : 5089178
}
EOCURRENT

my $forecast = <<'EOFCAST';
{
   "city" : {
      "population" : 0,
      "country" : "United States of America",
      "coord" : {
         "lat" : 42.9912,
         "lon" : -71.4631
      },
      "name" : "Manchester",
      "id" : "5089178"
   },
   "cod" : "200",
   "list" : [
      {
         "pressure" : 1049.98,
         "dt" : 1397750400,
         "temp" : {
            "morn" : 40.28,
            "night" : 30.67,
            "eve" : 38.98,
            "min" : 30.67,
            "max" : 40.28,
            "day" : 40.28
         },
         "weather" : [
            {
               "icon" : "01d",
               "id" : 800,
               "description" : "sky is clear",
               "main" : "Clear"
            }
         ],
         "speed" : 8.81,
         "clouds" : 0,
         "deg" : 82,
         "humidity" : 55
      },
      {
         "pressure" : 1041.91,
         "dt" : 1397836800,
         "temp" : {
            "morn" : 29.19,
            "night" : 34.83,
            "eve" : 39.81,
            "min" : 29.19,
            "max" : 40.95,
            "day" : 39.94
         },
         "weather" : [
            {
               "icon" : "04d",
               "id" : 803,
               "description" : "broken clouds",
               "main" : "Clouds"
            }
         ],
         "speed" : 7.5,
         "clouds" : 80,
         "deg" : 79,
         "humidity" : 74
      },
      {
         "pressure" : 1029.22,
         "dt" : 1397923200,
         "temp" : {
            "morn" : 32.54,
            "night" : 47.48,
            "eve" : 57.61,
            "min" : 32.54,
            "max" : 57.61,
            "day" : 49.33
         },
         "weather" : [
            {
               "icon" : "01d",
               "id" : 800,
               "description" : "sky is clear",
               "main" : "Clear"
            }
         ],
         "speed" : 3.37,
         "clouds" : 0,
         "deg" : 249,
         "humidity" : 69
      }
   ],
   "cnt" : 3,
   "message" : 0.0058
}
EOFCAST

[ $current, $forecast ]
