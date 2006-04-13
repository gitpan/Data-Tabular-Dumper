use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Data::Tabular::Dumper',
    'VERSION_FROM' => 'Dumper.pm', # finds $VERSION
    dist=>{COMPRESS=>'gzip -9f', EXT=>'gz'},
    'PREREQ_PM'     => {
            'Data::Denter'=>0.1
    }
);
