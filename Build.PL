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
        'CGI::Cookie' => 0,
        'MIME::Base64' => 0,
        'Digest::SHA1' => 0,
    },
    recommends => {
        'Digest::MD5' => 0,
        'CGI::Application::Plugin::Session' => 0,
        'Apache::Htpasswd' => '1.6.1',
        'Color::Calc' => '0.12',
    },
    build_requires => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'Test::Warn' => 0,
    },
    create_makefile_pl => 'traditional',
    dist_author => 'Cees Hek <ceeshek@gmail.com>',
)->create_build_script;

