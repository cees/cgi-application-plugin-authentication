use Module::Build;

Module::Build->new(
    module_name => 'CGI::Application::Plugin::Authentication',
    license => 'perl',
    requires => {
        'CGI::Application' => 4,
        'Scalar::Util' => 0,
        'Class::ISA' => 0,
        'Attribute::Handlers' => 0,
        'UNIVERSAL::require' => 0,
        'CGI' => '3.16',
        'MIME::Base64' => 0,
        'Digest::SHA1' => 0,
        'perl' => 5.006,
    },
    recommends => {
        'Digest::MD5' => 0,
        'CGI::Application::Plugin::Session' => 0,
        'Apache::Htpasswd' => '1.8',
        'Color::Calc' => '0.12',
    },
    build_requires => {
        'Test::More' => 0,
        'Test::Warn' => 0.11, # older versions may have problems with fresh Sub::Uplevel
        'Task::Weaken' => 0, # to be sure that Scalar::Util has weaken
	'Test::Exception' => 0,
	'Test::Regression' => 0, # login_bix generates a lot of HTML to verify
	'Test::Taint' => 0
    },
    meta_merge => {
        resources=> {
            repository => 'http://github.com/cees/cgi-application-plugin-authentication/tree',
        },
        keywords => ['cgiapp','Titanium','authentication'],
    },
    create_makefile_pl => 'traditional',
    dist_author => 'Cees Hek <ceeshek@gmail.com>',
)->create_build_script;

