package Authen::Simple::Dummy;

use strict;
use warnings;
use base 'Authen::Simple::Adapter';

__PACKAGE__->options({
    testuser => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    testpass => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
});


sub check {
    my ( $self, $username, $password ) = @_;
    return $username eq $self->testuser &&  $password eq $self->testpass ? 1 : 0;
}

1;
