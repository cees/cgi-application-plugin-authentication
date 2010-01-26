#!/usr/bin/perl -T
use Test::More;
use Test::Taint;
use Test::Regression;

plan tests => 12;

use strict;
use warnings;

use CGI ();
taint_checking_ok('taint checking is on');

{

    package TestAppAuthenticate;

    use base qw(CGI::Application);
    use CGI::Application::Plugin::Authentication;

    __PACKAGE__->authen->config(
        DRIVER => [ 'Generic', { user1 => '123' } ],
	STORE => ['Cookie', SECRET => "Shhh, don't tell anyone", NAME => 'CAPAUTH_DATA', EXPIRY => '+1y'],
        POST_LOGIN_CALLBACK => \&post_login, 
    );

    sub setup {
        my $self = shift;
        $self->start_mode('one');
        $self->run_modes([qw(one two)]);
        $self->authen->protected_runmodes(qw(two));
    }

    sub one {
        my $self = shift;
    }

    sub two {
        my $self = shift;
    }

    sub post_login {
      my $self = shift;

      my $count=$self->param('post_login')||0;
      $self->param('post_login' => $count + 1 );
    }

}

$ENV{CGI_APP_RETURN_ONLY} = 1;

# Missing Credentials
my $param = { authen_username => 'user1', rm => 'two' };
taint($param->{authen_username});
taint($param->{rm});
my $query = CGI->new( $param);

my $cgiapp = TestAppAuthenticate->new( QUERY => $query );

my $results = $cgiapp->run;

ok(!$cgiapp->authen->is_authenticated,'missing credentials - login failure');
is( $cgiapp->authen->username, undef, 'missing credentials - username not set' );
is( $cgiapp->param('post_login'),1,'missing credentials - POST_LOGIN_CALLBACK executed' );
is( $cgiapp->authen->_detaint_destination, '', '_detaint_destination');
untainted_ok($cgiapp->authen->_detaint_destination, '_detaint_destination untainted');
is( $cgiapp->authen->_detaint_selfurl, 'http://localhost?rm=two;authen_username=user1', '_detaint_selfurl');
untainted_ok($cgiapp->authen->_detaint_selfurl, '_detaint_selfurl untainted');
is( $cgiapp->authen->_detaint_url, '', '_detaint_url');
untainted_ok($cgiapp->authen->_detaint_url, '_detaint_url untainted');
ok_regression(sub {$cgiapp->authen->login_box}, 't/out/login0', 'verify login box');
untainted_ok($cgiapp->authen->login_box, 'check login box taint');

