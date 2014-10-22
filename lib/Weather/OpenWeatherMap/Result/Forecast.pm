package Weather::OpenWeatherMap::Result::Forecast;
$Weather::OpenWeatherMap::Result::Forecast::VERSION = '0.001005';
use v5.10;
use strictures 1;
use Carp;

use Types::Standard      -all;
use List::Objects::Types -all;

use Weather::OpenWeatherMap::Result::Forecast::Day;

=pod

=for Pod::Coverage lazy_for

=cut

sub lazy_for {
  my $type = shift;
  (
    lazy => 1, is => 'ro', isa => $type,
    ( $type->has_coercion ? (coerce => 1) : () ),
    @_
  )
}

use namespace::clean; use Moo; use MooX::late;
extends 'Weather::OpenWeatherMap::Result';


has id => ( lazy_for Int,
  builder => sub { shift->data->{city}->{id} },
);

has name => ( lazy_for Str,
  builder => sub { shift->data->{city}->{name} },
);

has country => ( lazy_for Str,
  builder => sub { shift->data->{city}->{country} },
);

has latitude => ( lazy_for StrictNum,
  builder => sub { shift->data->{city}->{coord}->{lat} },
);

has longitude => ( lazy_for StrictNum,
  builder => sub { shift->data->{city}->{coord}->{lon} },
);

has count => ( lazy_for Int,
  builder => sub { shift->data->{cnt} // 0 },
);

has _forecast_list => ( lazy_for ArrayObj,
  builder => sub { 
    my @list = @{ shift->data->{list} || [] };
    [ map {;
      ref $_ eq 'HASH' ?
        Weather::OpenWeatherMap::Result::Forecast::Day->new(%$_)
        : carp "expected a HASH but got $_"
    } @list ]
  },
);

sub as_array {
  my ($self) = @_;
  $self->_forecast_list->copy
}

=for Pod::Coverage as_list

=cut

{ no warnings 'once'; *as_list = *list }
sub list {
  my ($self) = @_;
  $self->_forecast_list->all
}

sub iter {
  my ($self) = @_;
  $self->_forecast_list->natatime(1)
}


1;

=pod

=head1 NAME

Weather::OpenWeatherMap::Result::Forecast - Weather forecast result

=head1 SYNOPSIS

  # Normally retrieved via Weather::OpenWeatherMap

=head1 DESCRIPTION

This is a subclass of L<Weather::OpenWeatherMap::Result> containing the
result of a completed L<Weather::OpenWeatherMap::Request::Forecast>.

These are normally emitted by a L<Weather::OpenWeatherMap> instance.

=head2 ATTRIBUTES

=head3 count

The number of forecasts (days) as returned by the L<OpenWeatherMap
API|http://www.openweathermap.org/api>.

See L</list> and L</iter>.

=head3 country

The country string.

=head3 id

The L<OpenWeatherMap|http://www.openweathermap.org/> city code.

=head3 latitude

The station's latitude.

=head3 longitude

The station's longitude.

=head3 name

The city name.

=head2 METHODS

=head3 as_array

The full forecast list, as a L<List::Objects::WithUtils::Array>.

See L</list>.

=head3 list

The full forecast list; each item in the list is a
L<Weather::OpenWeatherMap::Result::Forecast::Day> instance:

  for my $day ($result->list) {
    my $date = $day->dt->mdy;
    my $cloudiness = $day->cloud_coverage;
    # ...
  }

See the documentation for
L<Weather::OpenWeatherMap::Result::Forecast::Day>.

=head3 iter

Returns an iterator that, when called, returns the next
L<Weather::OpenWeatherMap::Result::Forecast::Day> instance (or undef
when the list is empty):

  my $iter = $result->iter;
  while (my $day = $iter->()) {
    my $wind = $day->wind_speed_mph;
    # ...
  }

See the documentation for
L<Weather::OpenWeatherMap::Result::Forecast::Day>.

See also: L</list>

=head1 SEE ALSO

L<http://www.openweathermap.org>

L<Weather::OpenWeatherMap>

L<Weather::OpenWeatherMap::Result>

L<Weather::OpenWeatherMap::Result::Forecast::Day>

L<Weather::OpenWeatherMap::Result::Current>

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut
