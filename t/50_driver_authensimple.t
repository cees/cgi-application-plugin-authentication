#!/usr/bin/perl
use Test::More;
use lib qw(t);
eval "use Authen::Simple";
plan skip_all => "Authen::Simple required for this test" if $@;

plan tests => 8;

use strict;
use warnings;

{
    package TestAppDriverAuthenSimple;

    use base qw(TestAppDriver);

    __PACKAGE__->authen->config(
        DRIVER => [ 'Authen::Simple::Dummy', testuser => 'user1', testpass => '123' ],
        STORE  => 'Store::Dummy',
    );

}

TestAppDriverAuthenSimple->run_authen_tests(
    [ 'authen_username', 'authen_password' ],
    [ 'user1', '123' ],
);


TestAppDriverAuthenSimple->run_authen_failure_tests(
    [ 'authen_username', 'authen_password' ],
    [ 'user1', '1234' ],
);

