package Struct::Flatten::Template;

use Moose;

use version 0.77; our $VERSION = version->declare('v0.1.0');

=head1 NAME

Struct::Flatten::Template - flatten structures using a template

=head1 SYNOPSYS

  use Struct::Flatten::Template;

  my $tpl = {
    docs => [
      {
         key => \ { column => 0 },
         sum => {
            value => \ { column => 1 },
      }
    ],
  };

  my @data = ( );

  my $hnd = sub {
    my ($obj, $val, $args) = @_;

  };


=cut

has 'handler' => (
    is  => 'ro',
    isa => 'Maybe[CodeRef]',
);

has 'template' => (
    is => 'ro',
    isa => 'Ref',
);

sub process {
    my ($self, @args) = @_;

    my $struct = $args[0];
    my $template = $#args ? $args[1] : $self->template;
    my $index  = $args[2];

    if (my $type = (ref $template)) {

        if (($type eq 'REF') && (ref(${$template}) eq 'HASH') &&
            (my $fn = $self->handler)) {

            my %args = %{${$template}};
            $args{_index} = $index if defined $index;

            $fn->($self, $struct, \%args);
        }

        return if ($type ne ref($struct));

        my $method = "process_${type}";
        $method =~ s/::/_/g;

        if (my $fn = $self->can($method)) {
            $self->$fn($struct, $template);
        }
    }
 }


sub process_HASH {
    my ($self, $struct, $template) = @_;

    foreach my $key (keys %{$template}) {
        $self->process( $struct->{$key}, $template->{$key}, $key )
            if exists $struct->{$key};
    }
}

sub process_ARRAY {
    my ($self, $struct, $template) = @_;
    my $index = 0;
    $self->process( $_, $template->[0], $index++ )
        for @{$struct};
}

use namespace::autoclean;

1;
