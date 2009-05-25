package Pidgin::Web::Controller::Status;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use XML::Simple;
=head1 NAME

Pidgin::Web::Controller::Status - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    $c->response->body('Matched Pidgin::Web::Controller::Status in Status.');
}

sub list:Local{
	my ($self,$c) =@_;
	my @statuses;
	my $pidgin=$c->config->{pidgin};
	my $current=$pidgin->PurpleSavedstatusGetCurrent();
	my %icons=(
		1=>'IconStatus22Offline',
		2=>'IconStatus22Available',
		3=>'IconStatus22Busy',
		4=>'IconStatus22Invisible',
		5=>'IconStatus22Away',
		6=>'IconStatus22ExtendedAway',
		7=>'IconPhone',
	);
	my %favicons=(
		1=>'tray-offline.png',
		2=>'tray-online.png',
		3=>'tray-busy.png',
		4=>'tray-invisible.png',
		5=>'tray-away.png',
		6=>'tray-extended-away.png',
	);
	my %primitives=(
	    PURPLE_STATUS_UNSET => 0,
	    PURPLE_STATUS_OFFLINE=>1,
	    PURPLE_STATUS_AVAILABLE=>2,
	    PURPLE_STATUS_UNAVAILABLE=>3,
	    PURPLE_STATUS_INVISIBLE=>4,
	    PURPLE_STATUS_AWAY=>5,
	    PURPLE_STATUS_EXTENDED_AWAY=>6,
	    PURPLE_STATUS_MOBILE=>7,
	    PURPLE_STATUS_NUM_PRIMITIVES=>8
	);
	
	foreach my $prim (@primitives{qw/PURPLE_STATUS_AVAILABLE PURPLE_STATUS_AWAY PURPLE_STATUS_INVISIBLE PURPLE_STATUS_OFFLINE/}){
	    my $status={};
	    $status->{label}=$pidgin->PurplePrimitiveGetNameFromType($prim);
	    $status->{type} =$prim;
	    $status->{primitive}=1;
	    $status->{id}=$prim;
	    $status->{icon}=$icons{$prim};
	    $status->{favicon}=$favicons{$prim};
	    push @statuses,$status;
	};

	foreach my $id (@{$pidgin->PurpleSavedstatusesGetPopular(6)}){
#		next unless $id>0;
		my $account={};
		$account->{id}=$id;
		$account->{label}=$pidgin->PurpleSavedstatusGetTitle($id);
		$account->{type}=$pidgin->PurpleSavedstatusGetType($id);
		$account->{message}=$pidgin->PurpleSavedstatusGetMessage($id);
		$account->{icon}=$icons{$account->{type}};
		$account->{favicon}=$favicons{$account->{type}};
		$account->{current}=$current==$id;
		#die Dumper $pidgin->PurpleGetIms();
#		$account->{connected}=$pidgin->PurpleAccountIsConnected($id);
#		$account->{type}=$pidgin->PurpleAccountGetProtocolName($id);
#		$account->{remember_password}=$pidgin->PurpleAccountGetRememberPassword($id);
#		$account->{check_mail}=$pidgin->PurpleAccountGetCheckMail($id);
		
		push @statuses,$account;
	}
	$c->res->body(XMLout \@statuses);
}
sub remove:Local{
	my ($self,$c) =@_;
	my $label=$c->req->param('label');
	my $pidgin=$c->config->{pidgin};
	$pidgin->PurpleSavedstatusDelete($label);
	$c->res->body(1);
}
sub types:Local{
	my ($self,$c) =@_;
	my $pidgin=$c->config->{pidgin};
	my @types;
	#$pidgin->PurplePrimitiveGetIdFromType($_),
	for (1..7){
		push @types,{
			id=>$_,
			label=>$pidgin->PurplePrimitiveGetNameFromType($_)
		};
	}
	$c->res->body(XMLout \@types);
}
sub change:Local{
	my ($self,$c) =@_;
	my $pidgin=$c->config->{pidgin};
	my $id=$c->req->param('id');
	my $primitive=$c->req->param('primitive')&&$id;
	if ($primitive){
	$id=$pidgin->PurpleSavedstatusFindTransientByTypeAndMessage($primitive, '');
	    unless ($id)
	    {
			$id = $pidgin->PurpleSavedstatusNew(undef, $primitive);
			$pidgin->PurpleSavedstatusSetMessage($id, '');
	    }
	}
	$pidgin->PurpleSavedstatusActivate($id);
	$c->res->body('1');
}
sub add:Local{
	my ($self,$c) =@_;
	my $primitive=$c->req->param('primitive');
	my $message=$c->req->param('message');
	my $title=$c->req->param('title');
	my $pidgin=$c->config->{pidgin};
	my $id=$pidgin->PurpleSavedstatusNew($title,$primitive);
	$pidgin->PurpleSavedstatusSetMessage($id,$title);
	$c->res->body('1');
}
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
