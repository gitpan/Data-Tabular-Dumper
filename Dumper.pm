# $Id$
package Data::Tabular::Dumper;

use strict;
use vars qw($VERSION @ISA);

use Carp;

$VERSION="0.02";

# Preloaded methods go here.


###########################################################
sub open
{
    my($package, %writers)=@_;
    my $self=bless {writers=>{}, fields=>[]}, $package;

    my($object, $one);
    WRITER:
    foreach my $p1 (keys %writers) {
        foreach my $p2 ($p1, __PACKAGE__.'::'.$p1) {
            if($p2->can('open') and $p2->can('close') and $p2->can('write')) {
                $package=$p2 ;
                eval {
                    $object=$package->open($writers{$p1});
                };
                carp $@ if $@;
                if($object) {
                    $self->{writers}{$package}=$object;
                    $one=1;
                }
                next WRITER;
            }
        }
        carp "Could not find a valid package for $p1 (".__PACKAGE__."::$p1)";
    }
    return unless $one;
    return $self;
}

###########################################################
sub _doall
{
    my($name)=@_;
    return sub {
        my $self=shift @_;
        my $n;
        foreach my $o (values %{$self->{writers}}) {
            my $code=$o->can($name);
            if($code) {
                $code->($o, @_);
                $n++ unless $@;
            } else {
                carp "Object $o can not do $name";
            }
            carp $@ if $@;
        }
        return $n;
    };
}
###########################################################
*close=_doall('close');

###########################################################
*fields=_doall('fields');

###########################################################
*write=_doall('write');

###########################################################
sub DESTROY 
{
    $_[0]->close;
}


###########################################################
sub available
{
    my($package)=@_;

    my(%res, $yes);
    foreach my $p (qw(CSV XML Excel)) {
        $yes=0;
        $yes=1 if exists $INC{"Data/Tabular/$p.pm"};
        unless($yes) {
            local $SIG{__DIE__}='DEFAULT';
            local $SIG{__WARN__}='IGNORE';
            $yes=eval "require Data::Tabular::Dumper::$p; 1;";
        };
        $res{$p}=$yes;
    }
    return \%res unless wantarray;
    return grep {$res{$_}} keys %res;
}

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Data::Tabular::Dumper - Seamlessly dump tabular data to XML, CSV and XLS.

=head1 SYNOPSIS

    use Data::Tabular::Dumper;
    use Data::Tabular::Dumper::Excel;
    use Data::Tabular::Dumper::XML;

    # ....read in access_log and put data into $month

    $date=strftime('%Y%m%d', localtime);

    # output parsed access_log data in XML and XLS format
    my $dumper=Data::Tabular::Dumper->open(XML=>["$date.xml",
                                                 "access", "page"
                                                ],
                                            Excel=>["$date.xls"]);
    # what each field is called
    $dumper->fields([qw(uri hits bytes)]);

    # now output the data
    foreach my $URL (@$month) {
        $dumper->write($URL);
    }

    # sane shutdown
    $dumper->close();

This would produce the following XML :

    <?xml version="1.0" encoding="iso-8859-1"?>
    <access>
      <page>
        <uri>/index.html</uri>
        <hits>4000</hits>
        <bytes>5123412</bytes>
      </page>
      <page>
        <uri>/something/index.html</uri>
        <hits>400</hits>
        <bytes>51234</bytes>
      </page>
      <!-- more page tags here -->
    </access>

And an Excel file that looks roughly like this :

    uri                   hits     bytes
    /index.html            4000    5123412
    /something/index.html   400      51234
    ....

=head1 DESCRIPTION

Data::Tabular::Dumper aims to make it easy to turn tabular data into as many
file formats as possible.  It is useful when you need to provide data that
folks will then process further.  Because you don't really know what format
they want to use, you can provide as many as possible, and let them choose
which they want.

=head1 Data::Tabular::Dumper METHODS

=over 4

=item open(%writers)

Creates the Data::Tabular::Dumper object.  C<%writers> is a hash that
contains the the package of the object (as keys) and the parameters for it's
C<new()> function (as values).  As a convienience, the
Data::Tabular::Dumper::* modules can be specified as XML, Excel or CSV.  The 
above exampel would create 2 objects, via the following calls :

    Data::Tabular::Dumper::XML->new(["$date.xml","users", "user"]);
    Data::Tabular::Dumper::Excel->new(["$date.xls"]);

You can also create your own packages.  See WRITER OBJECTS below.

=item close()

Does an orderly close of all the writers.  Some of the writers need this to
clean up data and write file footers properly.   Note that DESTROY also
calls close.

=item fields($fieldref)

Sets the column headers to the values in the arrayref $fieldref.  Calling
this "fields" might be misdenomer.  Field headers are often concidered a
"special" row of data.

=item write($dataref)

Writes a row of data from the arrayref $dataref.

=back

=head1 WRITER OBJECTS

An object must implement 4 methods for it to be useable by
Data::Tabular::Dumper.

=over 4

=item open($package, $p)

Create the object.  C<$p> is the data handed to Data::Tabular::Dumper->open
(often an arrayref).

=item close()

Do any clean up necesssary, like closing the file.

=item fields($fieldref)

$fieldref is an arrayref containing all the field headings.

=item write($dataref)

$dataref is an arrayref containing a row of data to be output.

=back

=head1 PREDEFINED OBJECTS











=head2 Data::Tabular::Dumper::XML

Produces an XML file of the tabular data.

=over 4

=item open($package, [$file, $top, $record])

Opens the file C<$file>.  The top element is C<$top> and defaults to DATA. 
Each record is a C<$record> element and defaults to RECORD.

=item fields($fieldref)

Define the tag for each data value.

=item write($dataref)

Output a record.  Each item in the arrayref C<$dataref> becomes an element
named by the corresponding item set in C<fields()>.  If there are more items
in C<$dataref> then fields, the last field name is duplicated. Example :

    $xml=Data::Tabular::Dumper::XML->open(['something.xml']);
    $xml->fields([qw(foo bar)]);
    $xml->write([0..5]);

Would produce the following XML :

    <?xml version="1.0" encoding="iso-8859-1"?>
    <DATA>
      <RECORD>
        <foo>0</foo>
        <bar>1</bar>
        <bar>2</bar>
        <bar>3</bar>
        <bar>4</bar>
        <bar>5</bar>
      </RECORD>
    </DATA>


=back



=head2 Data::Tabular::Dumper::CSV

Produces an CSV file of the tabular data.

=over 4

=item open($package, [$file, $CSVattribs])

Opens the file C<$file> and creates a Text::CSV_XS object using the
attributes in C<$CSVattribs>

Example :

    $xml=Data::Tabular::Dumper::CSV->open(['something.xml', 
                                          {eol=>"\n", binary=>1}]);
    $xml->fields([qw(foo bar)]);
    $xml->write("me,you", "other");

Would produce the following CSV :

    foo,bar
    "me,you",other

=back





=head2 Data::Tabular::Dumper::Excel

Produces an Excel workbook of the tabular data.

=over 4

=item open($package, [$file])

Creates the workbook C<$file>. 

=item fields($fieldref)

Creates a row in bold from the elements in the arrayref C<$fieldref>.

=back



=head1 AUTHOR

Philip Gwyn <perl at pied.nu>

=head1 SEE ALSO

Text::CSV(3), Spreadsheet::WriteExcel(3), XML,  perl(1).

=cut
