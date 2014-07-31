package Struct::Flatten::Template;

use Moose;

use version 0.77; our $VERSION = version->declare('v0.1.0');

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

    if (my $type = (ref $template)) {

        if (my $fn = $self->handler) {

            $fn->($self, $struct, ${$template})
                if (($type eq 'REF') &&
                    (ref( ${$template} ) eq 'HASH'));

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
        $self->process( $struct->{$key}, $template->{$key},  )
            if exists $struct->{$key};
    }
}

sub process_ARRAY {
    my ($self, $struct, $template) = @_;
    $self->process( $_, $template->[0] )
        for @{$struct};
}

use namespace::autoclean;

1;
