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

    my $idx = $args->{_index};
    my $col = $args->{column};

    $data[$idx] = [ ] if $idx > $#data;
    $data[$idx]->[$col] = $val;
  };

  my $data = {
    docs => [
      { key => 'A', sum => { value => 10 } },
      { key => 'B', sum => { value =>  4 } },
      { key => 'C', sum => { value => 18 } },
    ],
  };

  my $p = Struct::Flatten::Template->new(
    template => $tpl,
    handler  => $hnd,
  );

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

=head1 SEE ALSO

L<Hash::Flatten>

=head1 AUTHOR

Robert Rothenberg, C<< <rrwo at cpan.org> >>

=head1 ACKNOWLEDGEMENTS

=over

=item Foxtons, Ltd.

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Robert Rothenberg.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

=for readme stop

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=for readme continue

=cut
