use Test::More;
use strict; use warnings FATAL => 'all';

use Weather::OpenWeatherMap;
use Weather::OpenWeatherMap::Test;

my $wx = Weather::OpenWeatherMap->new(
  api_key => 'foo',
  ua => mock_http_ua,
);


# Current
my $result = $wx->get_weather(
  location => 'Manchester, NH',
);

isa_ok $result, 'Weather::OpenWeatherMap::Result::Current',
  'got Result::Current ok';


# Forecast
$result = $wx->get_weather(
  location => 'Manchester, NH',
  forecast => 1,
  days     => 3,
);

isa_ok $result, 'Weather::OpenWeatherMap::Result::Forecast',
  'got Result::Forecast ok';

done_testing
