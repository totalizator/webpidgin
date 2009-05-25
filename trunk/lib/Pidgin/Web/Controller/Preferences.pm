package Pidgin::Web::Controller::Preferences;

use strict;
use warnings;
use Cwd;
use base 'Catalyst::Controller';

=head1 NAME

Pidgin::Web::Controller::Preferences - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub get:Local{
    my ($self,$c)=@_;
    my $pidgin=$c->config->{pidgin};
    local $/=undef;
    open PREFS, '<' ,cwd().'/../../libpurple/example/'.$pidgin->PurpleUserDir().'/prefs.xml';
    $c->res->body(<PREFS>);
}

sub set:Local{
    my ($self,$c)=@_;
    my $pidgin=$c->config->{pidgin};
    my $path='/webpidgin'.$c->req->param('path');
    my $type=$c->req->param('type');
    my $value=$c->req->param('value');
    my $method="PurplePrefsSet$type";
    $pidgin->$method($path,$value);
    $c->res->body('<ok />');
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
