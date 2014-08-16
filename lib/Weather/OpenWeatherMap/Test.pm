package Weather::OpenWeatherMap::Test;
$Weather::OpenWeatherMap::Test::VERSION = '0.002003';
=pod

=for Pod::Coverage .*

=cut

use v5.10;
use strictures 1;
use Carp;

use Path::Tiny;

use File::ShareDir 'dist_dir', 'dist_file';

use parent 'Exporter::Tiny';
our @EXPORT = our @EXPORT_OK = qw/
  get_test_data
  mock_http_ua
/;


sub get_test_data {
  my $type = lc (shift || return);

  my $base = 'Weather-OpenWeatherMap';
  my $path;
  DTYPE: {
    if ($type eq 'current') {
      $path = dist_file($base, 'current.json');
      last DTYPE
    }

    if ($type =~ /^3day/ || $type eq 'forecast') {
      $path = dist_file($base, '3day.json');
      last DTYPE
    }

    if ($type eq 'failure' || $type eq 'error') {
      $path = dist_file($base, 'failure.json');
      last DTYPE
    }

    if ($type eq 'find' || $type eq 'search') {
      $path = dist_file($base, 'find.json');
      last DTYPE
    }
  }

  if ($path) {
    return path($path)->slurp_utf8
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

1;
