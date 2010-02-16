#!/usr/bin/perl  -T
use Test::More;
use Test::Taint;
use Test::Exception;
use lib qw(t);

plan tests => 18;

use strict;
use warnings;
taint_checking_ok('taint checking is on');

use CGI ();

my $cap_options =
{
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

# Test 'find_options' function and what happens when we don't define 'verify_credentials'
{
	local $cap_options->{DRIVER} = 
	[
		'Silly',
		option1 => 'Tom',
		option2 => 'Dick',
		option3 => 'Harry'
	];
	my $query = CGI->new( { authen_username => 'user1', rm => 'two', authen_password=>'123', destination=>'http://news.bbc.co.uk' } );

	my $cgiapp = TestAppAuthenticate->new( QUERY => $query );

	my @drivers = $cgiapp->authen->drivers;
	ok(scalar(@drivers) == 1, 'We should have just one driver');

	ok($drivers[0]->find_option('option1', 'Tom'), 'Tom');
	ok($drivers[0]->find_option('option2', 'Dick'), 'Dick');
	ok($drivers[0]->find_option('option3', 'Harry'), 'Harry');
	throws_ok {$cgiapp->run} qr/verify_credentials must be implemented in the subclass/, 'undefined function caught okay';
};

# Test what happens when we have no options.
{
        local $cap_options->{DRIVER} =
        [
                'Silly',
        ];
        my $query = CGI->new( { authen_username => 'user1', rm => 'two', authen_password=>'123', destination=>'http://news.bbc.co.uk' } );

        my $cgiapp = TestAppAuthenticate->new( QUERY => $query );

	ok(!exists $cgiapp->authen->{drivers}, 'nothing cached yet');
        my @drivers = $cgiapp->authen->drivers;
        ok(scalar(@drivers) == 1, 'We should have just one driver');
	ok(scalar(@{$cgiapp->authen->{drivers}}) == 1, 'cached now');

	# test caching
	my @drivers1 = $cgiapp->authen->drivers;
        ok(scalar(@drivers1) == 1, 'We should have just one driver');
	ok($drivers[0] == $drivers1[0], 'test caching');

        ok(!defined($drivers[0]->find_option('option1', 'Tom')), 'Tom');
        ok(!defined($drivers[0]->find_option('option2', 'Dick')), 'Dick');
        ok(!defined($drivers[0]->find_option('option3', 'Harry')), 'Harry');
};

# Test what happens when no driver is defined
{
        my $query = CGI->new( { authen_username => 'user1', rm => 'two', authen_password=>'123', destination=>'http://news.bbc.co.uk' } );

        my $cgiapp = TestAppAuthenticate->new( QUERY => $query );

        my @drivers = $cgiapp->authen->drivers;
        ok(scalar(@drivers) == 1, 'We should have just one driver');
	isa_ok($drivers[0], 'CGI::Application::Plugin::Authentication::Driver::Dummy', 'Dummy is the default driver');
};

# Test what happens when a non-existent driver is called
{
        local $cap_options->{DRIVER} = ['Blah'];
        my $query = CGI->new( { authen_username => 'user1', rm => 'two', authen_password=>'123', destination=>'http://news.bbc.co.uk' } );

        my $cgiapp = TestAppAuthenticate->new( QUERY => $query );
	throws_ok {$cgiapp->authen->drivers} qr/Driver Blah can not be found/, 'Non existent driver';
};

# Test what happens when a driver constructor dies
{
        local $cap_options->{DRIVER} = ['Die'];
        my $query = CGI->new( { authen_username => 'user1', rm => 'two', authen_password=>'123', destination=>'http://news.bbc.co.uk' } );

        my $cgiapp = TestAppAuthenticate->new( QUERY => $query );
        throws_ok {$cgiapp->authen->drivers} qr/Could not create new CGI::Application::Plugin::Authentication::Driver::Die object/, 'Suicidal driver';
};


