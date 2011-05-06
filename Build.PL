use Module::Build;

Module::Build->new(
    module_name => 'CGI::Application::Plugin::Authentication',
    license     => 'perl',
    requires    => {
        'CGI::Application'    => 4,
        'Scalar::Util'        => 0,
        'Class::ISA'          => 0,
        'Attribute::Handlers' => 0,
        'UNIVERSAL::require'  => 0,
        'CGI'                 => '3.16',
        'MIME::Base64'        => 0,
        'Digest::SHA'         => 0,
        'perl'                => 5.006,
    },
    recommends => {
        'Digest::MD5'                       => 0,
        'CGI::Application::Plugin::Session' => 0,
        'Apache::Htpasswd'                  => '1.8',
        'Color::Calc'                       => '0.12',
    },
    build_requires => {
        'Test::More' => '0.93',
        'Test::Warn' =>
          0.11,    # older versions may have problems with fresh Sub::Uplevel
        'Test::MockObject' => 0,
        'Test::Exception'  => 0,
        'Test::NoWarnings' => 0,
        'Test::Regression' => 0, # login_box generates a lot of HTML to verify
        'Test::Taint'      => 0,
        'Test::Without::Module'      => 0,
        'Readonly' => 0,
    },
    meta_merge => {
        resources => {
            repository =>
'http://github.com/cees/cgi-application-plugin-authentication/tree',
        },
        keywords => [ 'cgiapp', 'Titanium', 'authentication' ],
    },
    create_readme=>1,
    create_makefile_pl => 'traditional',
    dist_author        => 'Cees Hek <ceeshek@gmail.com>',
)->create_build_script;

