use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Spotify::Control',
    AUTHOR           => q{Cameron Daniel <cdaniel@nurve.com.au>},
    VERSION_FROM     => 'lib/Spotify/Control.pm',
    ABSTRACT_FROM    => 'lib/Spotify/Control.pm',
    LICENSE          => 'open_source',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'URI' => 0,
        'JSON' => 0,
        'LWP::UserAgent' => 0,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Spotify-Control-*' },

    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'https://github.com/ccakes/p5-spotify-control',
                web => 'https://github.com/ccakes/p5-spotify-control'
            }
        }
    }
);
