#!/usr/bin/perl -T
use Test::More;
eval "use Test::Regression";
plan skip_all => "Test::Regression required for this test" if $@;
use Scalar::Util qw(tainted);

plan tests => 11;

use strict;
use warnings;

use CGI ();

{

    package TestAppAuthenticate;

    use base qw(CGI::Application);
    CGI::Application::Plugin::Session->import; # it was used conditionally above 
    use CGI::Application::Plugin::Authentication;

    __PACKAGE__->authen->config(
        DRIVER => [ 'Generic', { user1 => '123' } ],
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
my $query =
  CGI->new( { authen_username => 'user1', rm => 'two' } );

my $cgiapp = TestAppAuthenticate->new( QUERY => $query );

my $results = $cgiapp->run;

ok(!$cgiapp->authen->is_authenticated,'missing credentials - login failure');
is( $cgiapp->authen->username, undef, 'missing credentials - username not set' );
is( $cgiapp->param('post_login'),1,'missing credentials - POST_LOGIN_CALLBACK executed' );
ok_regression(sub {$cgiapp->authen->login_box}, 't/out/login0', 'verify login box');
is(tainted($cgiapp->authen->login_box), 'check login box taint');

