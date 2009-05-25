package Pidgin::Web::Controller::User;

use strict;
use warnings;
use Data::Dumper;
use base 'Catalyst::Controller';

=head1 NAME

Pidgin::Web::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub list : Local {
    my ( $self, $c ) = @_;
    my $page=$c->req->param('page')||1;
    my @users=$c->model('Users')->slice(($page-1)*30,$page*30);
    die Dumper \@users;
    $c->stash->{template}='/user/list.msn';
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
