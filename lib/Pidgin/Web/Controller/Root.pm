package Pidgin::Web::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Digest::SHA1 qw/sha1_hex/;
#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Pidgin::Web::Controller::Root - Root Controller for Pidgin::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut
sub auto:Private{
    my ( $self, $c ) = @_;
    if ($c->user_exists || $ENV{TEST_USER_ID}){
	$c->dbus_lock;
	my $user=$ENV{TEST_USER_ID}||$c->user->obj->id;
	my $obj=$c->model('DbusSession')->find({user=>$user});
	my $session=$obj->session;
	my $pid=$obj->pid;
	my $bus=Net::DBus->system;
	$c->res->cookies->{id}={value=>$user};
	my $pidgin=$bus->get_service('im.pidgin.purple.PurpleService'.$user)->get_object("/im/pidgin/purple/PurpleObject","im.pidgin.purple.PurpleInterface");
	Pidgin::Web->config(pidgin=>$pidgin);

    }
    1;
}
sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->content_type('text/html');
    if ($c->user_exists){
	$c->stash->{template}='index.msn';
    } else {
	$c->stash->{template}='login.msn';
	$c->stash->{failed}=1 if $c->req->param('failed')
    }
}
sub signup :Local{
    my ( $self, $c ) = @_;
    $c->model('Users')->new({
	email=>$c->req->param('email'),
	password=>sha1_hex($c->req->param('password'))
    })->insert;
    my %localENV=%ENV;
#    $localENV{}
    $c->detach('signin');
}
sub signin :Local{
    my ($self,$c) = @_;
    if ($c->login($c->req->param('email'),$c->req->param('password'))){
	$c->res->redirect('/');
    } else {
	$c->res->redirect('/?failed=true');
    }
}
=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {
    my ($self,$c)=@_;
    $c->remove_lock;
    $c->res->body && $c->res->content_type('application/xml')
}

=head1 AUTHOR

Andrey (GuGu) Kostenko

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
