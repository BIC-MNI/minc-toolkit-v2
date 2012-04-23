use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Getopt::Tabular',
    'VERSION_FROM' => 'Tabular.pm',
    'dist'      => { COMPRESS=>"gzip", SUFFIX=>"gz" }
);
