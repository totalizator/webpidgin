package Pidgin::Web::Controller::Account;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Net::DBus;
use XML::Simple;
=head1 NAME

Pidgin::Web::Controller::Account - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut
sub change:Local{
	my ($self,$c) =@_;
	my $pidgin=$c->config->{pidgin};
	my $id=$c->req->param('id');
	if ($c->req->param('delete')){
		$pidgin->PurpleAccountsRemove($id);
		$pidgin->PurpleAccountDestroy($id);
		$c->res->redirect($c->req->headers->referer);
		$c->detach();
	}
	my $checked=$c->req->param('checked');
	my $username=$c->req->param('username');
	my $password=$c->req->param('password');
	my $protocol=$c->req->param('protocol');
	my $alias=$c->req->param('alias');
	if ($checked){
		$pidgin->PurpleAccountConnect($id);
	} else {
		$pidgin->PurpleAccountDisconnect($id);
	}
#	die $protocol;
#	$pidgin->PurpleAccountSetProtocolId($id,$protocol);
	$pidgin->PurpleAccountSetUsername($id,$username);
	$pidgin->PurpleAccountSetAlias($id,$alias);
	if ($password){
		$pidgin->PurpleAccountSetPassword($id,$password);
	}
	$c->res->redirect($c->req->headers->referer);
}

sub add:Local{
	my ($self,$c) =@_;
	my $pidgin=$c->config->{pidgin};
	my $username=$c->req->param('username');
	my $protocol=$c->req->param('protocol');
	my $alias=$c->req->param('alias');
	my $id=$pidgin->PurpleAccountNew($username,$protocol);
	$c->stash->{id}=$id;
	my $checked=$c->req->param('checked');
	my $password=$c->req->param('password');
	my $remember_password=$c->req->param('remember_password');
	if ($checked){
		$pidgin->PurpleAccountConnect($id);
	} else {
		$pidgin->PurpleAccountDisconnect($id);
	}
#	die $protocol;
	#$pidgin->PurpleAccountSetProtocolId($id,$protocol);
	$pidgin->PurpleAccountSetUsername($id,$username);
	$pidgin->PurpleAccountSetAlias($id,$alias);
	if ($password){
		$pidgin->PurpleAccountSetPassword($id,$password);
		$pidgin->PurpleAccountSetRememberPassword($id,$remember_password)
	}
	$pidgin->PurpleAccountsAdd($id);
	$c->res->body('1');
	return;
#	$c->res->redirect($c->req->headers->referer);
}
sub test:Local{
	my ($self,$c) =@_;
    $self->list($c);
    $c->req->param('username'=>'193286886');
    $c->req->param('protocol'=>'prpl-icq');
    $c->req->param('alias'=>'I');
    $c->req->param('password'=>'******');
    $self->add($c);
    die "No ID" unless $c->stash->{id};
}
use Data::Dumper;
sub list:Local{
	my ($self,$c) =@_;
	my @accounts;
        my @protocols;
	my $pidgin=$c->config->{pidgin};
	foreach my $id (@{$pidgin->PurpleAccountsGetAll()}){
		my $account={};
		$account->{id}=$id;
#		die Dumper $pidgin->PurpleGetIms();
		$account->{connected}=1 if $pidgin->PurpleAccountIsConnected($id);#?"true":"false";
		$account->{protocol}=$pidgin->PurpleAccountGetProtocolName($id);
		$account->{username}=$pidgin->PurpleAccountGetUsername($id);
		$account->{alias}=$pidgin->PurpleAccountGetAlias($id);
		$account->{remember_password}=$pidgin->PurpleAccountGetRememberPassword($id);
		$account->{check_mail}=$pidgin->PurpleAccountGetCheckMail($id);
		my $icon=lc($account->{protocol});
		$icon=~s/(^|-)(.)/\u$2/g;
		$account->{proto_icon}='IconProtocols16'.$icon;
#		$pidgin->ServGetInfo($pidgin->PurpleAccountGetConnection($id),$account->{info});
		push @accounts,$account;
	}
        foreach my $pid (@{$pidgin->PurplePluginsGetProtocols()}){
	$c->log->info($pid);
	my $plugin={
	    id=>$pidgin->PurplePluginGetId($pid),
	    name=>$pidgin->PurplePluginGetName($pid),
	};
	$c->log->info($plugin->{id});
#	$c->log->info(Dumper($plugin->{splits}=$pidgin->PurplePrplHasUserSplits($pid)));
	my $icon=lc($plugin->{name});
	$icon=~s/(^|-)(.)/\u$2/g;
	$plugin->{icon}='IconProtocols22'.$icon;
	push @protocols,$plugin;
	};
#	$protocols[0]=$pidgin->PurpleAccountsGetUiOps();
	$c->res->body(XMLout 
	{
	    accounts=>\@accounts,
	    protocols=>\@protocols
	});
#	$c->stash->{accounts}=\@accounts;
#	$c->stash->{protocols}=\@protocols;
#	$c->stash->{template}='/account/list.msn';
}
sub protocols:Local{
    my ($self,$c) = @_;
    my $pidgin=$c->config->{pidgin};
    $c->res->body(XMLout );
}
sub connect:Local{
	my ($self,$c) =@_;
	my $id=$c->req->param('id');
	my $connected=$c->req->param('connected');
	my $pidgin=$c->config->{pidgin};
	if ((!$pidgin->PurpleAccountIsConnected($id)) == $connected){#Don't touch if all is ok
		$pidgin->PurpleAccountSetEnabled($id,$c->config->{name},$connected);
		return $c->res->body(2);
	};
	$c->res->body('res:'.$pidgin->PurpleAccountIsConnected($id));
}
sub icon:Path('icon'){
	my ($self,$c) =@_;
	my $id=$c->req->arguments->[0];
	my $pidgin=$c->config->{pidgin};
	my $icon=$pidgin->PurpleAccountGetBuddyIconPath($id);
	if ($icon){
		local $/=undef;
		open ICON, '<',$icon;
		my ($ext)=($icon=~/\.(.*?)$/);
		$c->res->content_type('image/'.$ext);
		$c->res->body(<ICON>);
	} else {
		$c->res->body(' ');
	}
}
sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Pidgin::Web::Controller::Account in Account.');
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
