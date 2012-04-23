use strict;
use warnings;

use lib "./inc";

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'Text::Format',
    license             => 'perl',
    dist_author         => q{Shlomi Fish <shlomif@cpan.org>},
    dist_version_from   => 'lib/Text/Format.pm',
    requires =>
    {
        'Carp' => 0,
        'vars' => 0,
        'strict' => 0,
        'warnings' => 0,
    },
    build_requires =>
    {
        'Test::More' => 0,
        'vars' => 0,
    },
    configure_requires =>
    {
        'Module::Build' => 0,
    },
    add_to_cleanup      => [ 'Module-Format-*' ],
    create_makefile_pl => 'traditional',
    meta_merge =>
    {
        resources =>
        {
            repository => "http://bitbucket.org/shlomif/web-cpan",
            homepage => "http://www.shlomifish.org/open-source/projects/Text-Format/",
        },
        keywords =>
        [
            'format',
            'formatting',
            'margin',
            'margins',
            'string',
            'text',
            'width',
        ],
    },
);

$builder->create_build_script();
