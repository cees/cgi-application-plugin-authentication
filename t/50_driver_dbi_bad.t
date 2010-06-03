#!/usr/bin/perl
use Test::More;
use Test::Exception;
use lib qw(t);
eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite required for this test" if $@;

plan tests => 1;

use strict;
use warnings;

our $DBNAME = 't/sqlite.db';

unlink $DBNAME if -e $DBNAME;
my $dbh = DBI->connect( "dbi:SQLite:dbname=$DBNAME", "", "" );

$dbh->do(<<"");
CREATE TABLE user (
    name VARCHAR(20),
    password VARCHAR(50)
)

$dbh->do(<<"");
INSERT INTO user VALUES ('user1', '123');

$dbh->do(<<"");
INSERT INTO user VALUES ('user2', 'mQPVY1HNg8SJ2');  # crypt("123", "mQ")


{

    package TestAppDriverDBISimple;

    use base qw(TestAppDriver);

    __PACKAGE__->authen->config(
        DRIVER => [
            [
                'DBI',
                DBH         => $dbh,
                TABLE       => undef,
                CONSTRAINTS => { 'user.name' => '__CREDENTIAL_1__', 'user.password' => '__CREDENTIAL_2__' },
            ],
        ],
        STORE => 'Store::Dummy',
    );

}

throws_ok {TestAppDriverDBISimple->run_authen_tests(
    [ 'authen_username', 'authen_password' ],
    [ 'user1', '123' ],
    [ 'user2', '123' ],
);}
   qr/Error executing class callback in prerun stage: No TABLE parameter defined/,
   "no TABLE";

