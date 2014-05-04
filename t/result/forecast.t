use Test::More;
use strict; use warnings FATAL => 'all';

use lib 't/inc';

use Weather::OpenWeatherMap::Test;

use Weather::OpenWeatherMap::Request;
use Weather::OpenWeatherMap::Result;

my $req = Weather::OpenWeatherMap::Request->new_for(
  Forecast =>
    api_key => 'abcd',
    tag     => 'foo',
    location => 'Manchester, NH',
);

my $mockjson = get_test_data('3day');

my $res = Weather::OpenWeatherMap::Result->new_for(
  Forecast =>
    request => $req,
    json    => $mockjson,
);

ok $res->id == 5089178, 'id ok';

ok $res->name eq 'Manchester', 'name ok';

ok $res->country eq 'United States of America', 'country ok';

ok $res->latitude eq '42.9912', 'latitude ok';
ok $res->longitude eq '-71.4631', 'longitude ok';

ok $res->count == 3, 'count ok';

ok $res->as_array->count == 3, 'as_array ok';

my @list = $res->list;
ok @list == 3, 'list has 3 elements';
for my $day (@list) {
  isa_ok $day, 'Weather::OpenWeatherMap::Result::Forecast::Day';
}

my $iter = $res->iter;

my $first = $iter->();

isa_ok $first->dt, 'DateTime';
ok $first->dt->epoch == 1397750400, 'dt ok';

ok $first->pressure eq '1049.98', 'day 1 pressure ok';
ok $first->humidity == 55, 'day 1 humidity ok';
ok $first->cloud_coverage == 0, 'day 1 cloud_coverage ok';
ok $first->wind_speed_mph == 8, 'day 1 wind_speed_mph ok';
ok $first->wind_speed_kph == 12, 'day 1 wind_speed_kph ok'
  or diag explain $first->wind_speed_kph;
ok $first->wind_direction eq 'E', 'day 1 wind_direction ok';
ok $first->wind_direction_degrees == 82, 'day 1 wind_direction_degrees ok';

isa_ok $first->temp,
  'Weather::OpenWeatherMap::Result::Forecast::Day::Temps';
ok $first->temp_min_f == 30, 'day 1 temp_min_f ok';
ok $first->temp_max_f == 40, 'day 1 temp_max_f ok';
ok $first->temp_min_c == -1, 'day 1 temp_min_c ok';
ok $first->temp_max_c == 4, 'day 1 temp_max_c ok';

ok $first->conditions_terse eq 'Clear', 'day 1 conditions_terse ok';
ok $first->conditions_verbose eq 'sky is clear', 'day 1 conditions_verbose ok';
ok $first->conditions_code == 800, 'day 1 conditions_code ok';
ok $first->conditions_icon eq '01d', 'day 1 conditions_icon ok';


my $second = $iter->();
ok $second->pressure == '1041.91', 'day 2 pressure ok';
ok $second->humidity == 74, 'day 2 humidity ok';
ok $second->cloud_coverage == 80, 'day 2 cloud_coverage ok';
ok $second->wind_speed_mph == 7, 'day 2 wind_speed_mph ok';
ok $second->wind_direction eq 'E', 'day 2 wind_direction ok';
ok $second->wind_direction_degrees == 79, 'day 2 wind_direction_degrees ok';

isa_ok $second->temp,
  'Weather::OpenWeatherMap::Result::Forecast::Day::Temps';
ok $second->temp_min_f == 29, 'day 2 temp_min_f ok';
ok $second->temp_max_f == 40, 'day 2 temp_max_f ok';

ok $second->conditions_terse eq 'Clouds', 'day 2 conditions_terse ok';
ok $second->conditions_verbose eq 'broken clouds', 'day 2 conditions_verbose ok';
ok $second->conditions_code == 803, 'day 2 conditions_code ok';
ok $second->conditions_icon eq '04d', 'day 2 conditions_icon ok';

# FIXME a bit incomplete ->
use Storable 'thaw';
my $frozen = $res->freeze;
my $clone = thaw $frozen;
isa_ok $clone, 'Weather::OpenWeatherMap::Result::Forecast';
ok $clone->as_array->count == 3, 'clone->as_array ok';
ok $clone->as_array->get(0)->temp_max_f == 40, 'cloned day 1 temp_max_f ok';


# FIXME test failure data ?


done_testing
