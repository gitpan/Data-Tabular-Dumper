# $Id$
package Data::Tabular::Dumper::Excel;
use strict;

use Spreadsheet::WriteExcel;

###########################################################
sub open 
{
    my($package, $param)=@_;
    my($file)=@$param;
    my $book=Spreadsheet::WriteExcel->new($file);
    my $sheet=$book->addworksheet();
    my $header=$book->addformat();
    $header->set_bold();
    my $default=$book->addformat();
    return bless {book=>$book, sheet=>$sheet, row=>0, header=>$header, 
                  default=>$default}, $package;
}

###########################################################
sub close
{
    my($self)=@_;
    undef $self->{sheet};
    undef $self->{header};
    $self->{book}->close();
    undef $self->{book};
}


###########################################################
sub __write
{
    my($self, $data, $format)=@_;
    my $row=$self->{row}++;
    my $col=0;
    foreach my $d (@$data) {
        $self->{sheet}->write($row, $col, $d, $format);
        $col++;
    }
}

###########################################################
sub fields
{
    my($self, $fields)=@_;
    $self->__write($fields, $self->{header});
}


###########################################################
sub write
{
    my($self, $data)=@_;
    $self->__write($data, $self->{default});
}

1;

__END__

$Log$