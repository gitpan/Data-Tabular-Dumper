# $Id$
package Data::Tabular::Dumper::CSV;
use strict;
use Text::CSV_XS;
use Data::Dumper;

###########################################################
sub open 
{
    my($package, $param)=@_;
    my($file, $attr)=@$param;

    my $fh=eval { local *FH;};
    open $fh, ">$file" or die "Unable to open $file: $!\n";
    
    my $csv=Text::CSV_XS->new($attr);
    die "No CSV\n" unless $csv;
    return bless {fh=>$fh, csv=>$csv}, $package;
}


###########################################################
sub close
{
    my($self)=@_;
    undef $self->{fh};
    undef $self->{csv};
}

###########################################################
sub write
{
    my($self, $data)=@_;
    my $fh=$self->{fh};
    $self->{csv}->combine(@$data);
    print $fh $self->{csv}->string;
}

###########################################################
*fields=\&write;

1;

__END__

$Log$