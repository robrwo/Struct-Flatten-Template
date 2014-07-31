use Test::Most;

use_ok('Struct::Flatten::Template');

my $tmpl = {
    foo => {
        bar => \ { column => 0 }
    },
    baz => [
        \ { column => 1 },
        ],
};

my $struct = {
    foo  => { bar => 'a', },
    baz  => [qw/ b c d /],
    boom => 10,
};

my @row;

sub handler {
    my ($obj, $val, $args) = @_;

    my $col = $args->{column};

    if (defined $row[$col]) {
        push @{$row[$col]}, $val;
    } else {
        $row[$col] = [ $val ];
    }
}

isa_ok
    my $p = Struct::Flatten::Template->new(
        handler  => \&handler,
        template => $tmpl,
    ),
    'Struct::Flatten::Template';

$p->process($struct);

is_deeply
    \@row,
    [ [qw/a/], [qw/b c d/] ],
    'expected result';

done_testing;
