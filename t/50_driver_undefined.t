#!/usr/bin/perl  -T
use Test::More;
use Test::Taint;
use Test::Exception;
use lib qw(t);

plan tests => 2;

use strict;
use warnings;
taint_checking_ok('taint checking is on');

use CGI ();

my $cap_options =
{
        DRIVER => [ 'Silly' ],
        STORE => ['Cookie', SECRET => "Shhh, don't tell anyone", NAME => 'CAPAUTH_DATA', EXPIRY => '+1y'],
};

{

    package TestAppAuthenticate;

    use base qw(CGI::Application);
    use CGI::Application::Plugin::Authentication;

    sub setup {
        my $self = shift;
        $self->start_mode('one');
        $self->run_modes([qw(one two three)]);
        $self->authen->protected_runmodes(qw(two three));
        $self->authen->config($cap_options);
    }

    sub one {
        my $self = shift;
	return "<html><body>ONE</body></html>";
    }

    sub two {
        my $self = shift;
	return "<html><body>TWO</body></html>";
    }

    sub three {
        my $self = shift;
        return "<html><body>THREE</body></html>";
    }

    sub post_login {
      my $self = shift;

      my $count=$self->param('post_login')||0;
      $self->param('post_login' => $count + 1 );
    }

}

$ENV{CGI_APP_RETURN_ONLY} = 1;

# successful login
{
	my $query = CGI->new( { authen_username => 'user1', rm => 'two', authen_password=>'123', destination=>'http://news.bbc.co.uk' } );

	my $cgiapp = TestAppAuthenticate->new( QUERY => $query );
	throws_ok {$cgiapp->run} qr/verify_credentials must be implemented in the subclass/, 'undefined function caught okay';
};
