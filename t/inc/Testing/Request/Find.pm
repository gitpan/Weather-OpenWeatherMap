package Testing::Request::Find;

use Test::Roo::Role;
with 'Testing::Request';

has request_obj_bycode => (
  is      => 'ro',
  builder => sub { 1 },
);

has rx_base => (
  is      => 'ro',
  builder => sub {
    '^http://api\.openweathermap\.org/data/2\.5/find\?'
  },
);


test 'find request url by name' => sub {
  my ($self) = @_;
  my $re = $self->rx_base 
            . 'q=\S+&units='
            . $self->request_obj->_units
            . '&type='
            . $self->request_obj->type
            . '&cnt='
            . $self->request_obj->max;
  cmp_ok $self->request_obj->url, '=~', $re, 'by name';
};

test 'find request url by coord' => sub {
  my ($self) = @_;
  my $re = $self->rx_base
            . 'lat=\S+&lon=\S+&units='
            . $self->request_obj_bycoord->_units
            . '&type='
            . $self->request_obj->type
            . '&cnt='
            . $self->request_obj_bycoord->max;
  cmp_ok $self->request_obj_bycoord->url, '=~', $re, 'by coord';
};


1;
