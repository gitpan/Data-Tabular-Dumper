# $Id$
package Data::Tabular::Dumper::XML;
use strict;

###########################################################
sub open
{
    my($package, $param)=@_;
    my($file, $top, $record)=@$param;
    $top||='DATA';
    $record||='RECORD';
    my $fh=eval { local *FH;};

    open $fh, ">$file" or die "Unable to open $file: $!\n";

    print $fh qq(<?xml version="1.0" encoding="iso-8859-1"?>\n<$top>\n);

    return bless {fh=>$fh, fields=>[], top=>$top, record=>$record}, $package;
}

###########################################################
sub close
{
    my($self)=@_;
    my $fh=$self->{fh};
    print $fh qq(</$self->{top}>\n);
    undef $self->{fh};
}

###########################################################
sub fields
{
    my($self, $fields)=@_;
    $self->{fields}=[@$fields];
}

###########################################################
sub write
{
    my($self, $data)=@_;

    my $fh=$self->{fh};
    print $fh qq(  <$self->{record}>\n);
    foreach my $q (0..$#$data) {
        my $f=$self->{fields}[$q > $#{$self->{fields}} ? -1 : $q];
        my $d=$data->[$q];
        next unless defined $d;
        $d=~s/&/&amp;/g;
        $d=~s/</&lt;/g;
        $d=~s/>/&gt;/g;
        print $fh qq(    <$f>$d</$f>\n);
    }
    print $fh qq(  </$self->{record}>\n);
}

1;

__END__

$Log$