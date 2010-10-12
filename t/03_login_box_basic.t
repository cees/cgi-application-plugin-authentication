#!/usr/bin/perl -T
use Test::More;
use Test::Taint;
use Test::Regression;
use English qw(-no_match_vars);

if ($OSNAME eq 'MSWin32') {
    my $msg = 'Not running these tests on windows yet';
    plan skip_all => $msg;
}
plan tests => 2;

use strict;
use warnings;

use CGI ();
taint_checking_ok('taint checking is on');
$ENV{CGI_APP_RETURN_ONLY} = 1;

my $cap_options = 
{
        DRIVER => [ 'Generic', { user1 => '123' } ],
	STORE => ['Cookie', SECRET => "Shhh, don't tell anyone", NAME => 'CAPAUTH_DATA', EXPIRY => '+1y'],
        POST_LOGIN_CALLBACK => \&TestAppAuthenticate::post_login, 
        LOGIN_FORM=>{
            DISPLAY_CLASS=>'Basic',
        },
};

{

    package TestAppAuthenticate;

    use base qw(CGI::Application);
    use CGI::Application::Plugin::Authentication;

    sub setup {
        my $self = shift;
        $self->start_mode('one');
        $self->run_modes([qw(one two)]);
        $self->authen->protected_runmodes(qw(two));
    	$self->authen->config($cap_options);
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

subtest 'empty' => sub {
    plan tests => 4;
    my $cgiapp = TestAppAuthenticate->new;

    my $results = $cgiapp->run;

    ok(!$cgiapp->authen->is_authenticated,"login failure");
    is( $cgiapp->authen->username, undef, "username not set" );
    my $display = $cgiapp->authen->display;
    isa_ok($display, 'CGI::Application::Plugin::Authentication::Display');
    isa_ok($display, 'CGI::Application::Plugin::Authentication::Display::Basic');
}
