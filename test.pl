# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..17\n"; }
END {print "not ok 1\n" unless $loaded;}
use Data::Tabular::Dumper;

$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $q=2;

my %params=(CSV=>["temp/test.csv", {eol=>"\n", binary=>1}], 
            XML=>["temp/test.xml", "table", "record" ],
            Excel=>["temp/test.xls"]);

my $allowed=Data::Tabular::Dumper->available();

# no way this would happen ... :)
print "not " unless grep {$allowed->{$_}} keys %$allowed;
print "ok $q\n";
$q++;

foreach my $w (qw(CSV XML Excel)) {
    my $dumper='';
    $dumper=Data::Tabular::Dumper->open($w=>$params{$w}) if $allowed->{$w};
    unless($dumper) {
        foreach (0..4) {
            print "skip $q\n";
            $q++;
        }
        next;
    }

    print "ok $q\n";
    $q++;

    $dumper->fields([qw(one two three)])    or print "not ";
    print "ok $q\n";
    $q++;
    $dumper->write([1..3])                  or print "not ";
    print "ok $q\n";
    $q++;
    $dumper->write([4..6]);
    $dumper->write([7..9]);
    $dumper->write(["one,un","<b>deux</b>","+@[123]"]) or print "not ";
    print "ok $q\n";
    $q++;
    $dumper->close or print "not ";
    print "ok $q\n";
    $q++;
}