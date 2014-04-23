use Test::More;
use strict; use warnings FATAL => 'all';

use Weather::OpenWeatherMap;
use Weather::OpenWeatherMap::Test;

my $wx = Weather::OpenWeatherMap->new(
  api_key => 'foo',
  ua      => mock_http_ua(),
);


# Current
my $result = $wx->get_weather(
  location => 'Manchester, NH',
);

isa_ok $result, 'Weather::OpenWeatherMap::Result::Current';
ok $result->name eq 'Manchester', 'result looks ok';


# Forecast
$result = $wx->get_weather(
  location => 'Manchester, NH',
  forecast => 1,
  days     => 3,
);

isa_ok $result, 'Weather::OpenWeatherMap::Result::Forecast';
ok $result->name eq 'Manchester', 'forecast result looks ok';
ok $result->list == 3, '3 days returned ok';

ok $wx->ua->requested_count == 2, 'mocked 2 http requests ok';

done_testing