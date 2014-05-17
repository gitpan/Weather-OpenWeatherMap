package Testing::OpenWeatherMap;

{ package Testing::OWM::Current;
  use Test::Roo;
  has [qw/request_obj result_obj mock_json/] => ( is => 'ro' );
  with 'Testing::Result::Current';
}
{ package Testing::OWM::Forecast;
  use Test::Roo;
  has [qw/request_obj result_obj mock_json/] => ( is => 'ro' );
  with 'Testing::Result::Forecast';
}

use Weather::OpenWeatherMap;
use Weather::OpenWeatherMap::Test;


use Test::Roo::Role;


has wx => (
  lazy    => 1,
  is      => 'ro',
  writer  => 'set_wx',
  builder => sub {
    Weather::OpenWeatherMap->new(
      api_key => 'foo',
      ua      => mock_http_ua(),
    )
  },
);

test 'retrieve current' => sub {
  my ($self) = @_;
  my $result = $self->wx->get_weather(
    location => 'Manchester, NH',
  );
  Testing::OWM::Current->run_tests( +{
    result_obj  => $result,
    request_obj => $result->request,
    mock_json   => $result->json,
  } );
};

test 'retrieve forecast' => sub {
  my ($self) = @_;
  my $result = $self->wx->get_weather(
    location => 'Manchester, NH',
    forecast => 1,
    days     => 3,
  );
  Testing::OWM::Forecast->run_tests( +{
    result_obj  => $result,
    request_obj => $result->request,
    mock_json   => $result->json,
  } );
};

test 'caching' => sub {
  my ($self) = @_;
  $self->set_wx(
    Weather::OpenWeatherMap->new(
      api_key => 'foo',
      ua      => mock_http_ua(),
      cache   => 1,
    )
  );

  my $result = $self->wx->get_weather(
    location => 'Manchester, NH',
  );

  ok $self->wx->_cache->is_cached($result->request),
    'result was cached';

  my $cached = $self->wx->get_weather(
    location => 'Manchester, NH',
  );
  Testing::OWM::Current->run_tests( +{
    result_obj  => $cached,
    request_obj => $cached->request,
    mock_json   => $cached->json,
  } );
};

1;
