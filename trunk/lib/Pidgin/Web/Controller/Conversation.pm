package Pidgin::Web::Controller::Conversation;
use Net::DBus qw/:typing/;
use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use XML::Simple;
=head1 NAME

Pidgin::Web::Controller::Conversation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Pidgin::Web::Controller::Conversation in Conversation.');
}

sub list:Local{
	my ( $self, $c ) = @_;
	my $pidgin=$c->config->{pidgin};
	my @conversations;
	my $cdata=$pidgin->PurpleGetConversations();
	foreach my $conv (ref $cdata? @$cdata : $cdata){
		my $item={};
		$item->{id} = $conv;
		$item->{name} = $pidgin->PurpleConversationGetName($conv);
		$item->{label} = $pidgin->PurpleConversationGetTitle($conv);
		$item->{im} = $pidgin->PurpleConversationGetImData($conv);
		if ($item->{im} && (my $icon = $pidgin->PurpleConvImGetIcon($item->{im}))){
		    $item->{icon} = $pidgin->PurpleBuddyIconGetFullPath($icon);
		    $item->{icon} =~s/.*\///;
		}
		$item->{chat} = $pidgin->PurpleConversationGetChatData($conv);
		if ($item->{chat}){
			$item->{title} = $pidgin->PurpleConvChatGetTopic($item->{chat});
		}		
		push @conversations,$item;
	}
	$c->res->body(XMLout \@conversations);
}
sub send:Local{
	my ( $self, $c ) = @_;
	my $type=$c->req->param('type');
	my $conv=$c->req->param('conv');
	my $message=$c->req->param('message');
	my $pidgin=$c->config->{pidgin};
	if ($type==2){
		$pidgin->PurpleConvChatSend($pidgin->PurpleConversationGetChatData($conv),$message)
	} elsif ($type==1){
		$pidgin->PurpleConvImSend($pidgin->PurpleConversationGetImData($conv),$message)
	}
	
}
sub add:Local{
	my ( $self, $c ) = @_;
	my $pidgin=$c->config->{pidgin};

=pod

        PURPLE_CONV_TYPE_UNKNOWN = 0, /**< Unknown conversation type. */                                                                                     
        PURPLE_CONV_TYPE_IM,          /**< Instant Message.           */                                                                                     
        PURPLE_CONV_TYPE_CHAT,        /**< Chat room.                 */                                                                                     
        PURPLE_CONV_TYPE_MISC,        /**< A misc. conversation.      */                                                                                     
        PURPLE_CONV_TYPE_ANY          /**< Any type of conversation.  */       

=cut
	my $type=$c->req->param('type');
	my $buddy=$c->req->param('buddy');
	my $account = ($type==1 ? $pidgin->PurpleBuddyGetAccount($buddy): $pidgin->PurpleChatGetAccount($buddy));
	my $name = ($type==1 ? $pidgin->PurpleBuddyGetName($buddy): $pidgin->PurpleChatGetName($buddy));
#	$pidgin->PurpleAccountGetLog($account,1);
#	$pidgin->PurpleConversationNew($type,$account,$name);
	if ($type==2){
#	    my $conn=$pidgin->PurpleAccountGetConnection($account);
	    $pidgin->ServJoinChatDbus($buddy); 
	} else {
	    $pidgin->PurpleConversationNew($type,$account,$name);
	}
	$c->res->body(1);	
}
sub chat_userlist:Local{
	my ( $self, $c ) = @_;
	my $pidgin=$c->config->{pidgin};
	my $chat=$c->req->param('chat');
	my @users;
	foreach my $user (@{$pidgin->PurpleConvChatGetUsers($chat)}){
		my $data={};
		$data->{id}=$user;
		$data->{name}=$pidgin->PurpleConvChatCbGetName($user);
		push @users,$data;
	}
#	PurpleConvChatGetName
	$c->res->body(XMLout(\@users));
	
}
sub logs:Local{
	my ( $self, $c ) = @_;
	my $pidgin=$c->config->{pidgin};
	my $id=$c->req->param('id')||die 'REQ:ID';
	my $item;
	my $type;
	my $log;
	my @logs;
	my $account=$pidgin->PurpleConversationGetAccount($id);
	my $name=$pidgin->PurpleConversationGetName($id);
	my $text;
	    if (my $item=$pidgin->PurpleConversationGetImData($id) ){
		my $buddies = $pidgin->PurpleFindBuddies($account, $name);
		return $c->res->body('') unless ($buddies);
		foreach my $buddy (@$buddies){
		    next unless $pidgin->PurpleLogGetTotalSize(0,$pidgin->PurpleBuddyGetName($buddy),$account);
		    $log=$pidgin->PurpleLogGetLogs(0,$pidgin->PurpleBuddyGetName($buddy),$account);
		}
	    } else {
		$item=$pidgin->PurpleConversationGetChatData($id);
		$log=$pidgin->PurpleLogGetLogs(1,$pidgin->PurpleConversationGetName($id),$pidgin->PurpleConversationGetAccount($id));		
	    }
	    my $i={};
	    if ($log){
		$i->{id}=$log->[0];
		$text.=$pidgin->PurpleLogReadDef($log->[0]);
	    }
	$text||=' ';
	$c->res->body($text);
}

sub remove:Local{
    my ( $self , $c ) = @_;
    my $pidgin=$c->config->{pidgin};
    my $id=$c->req->param('id')||die 'REQ:ID';
    $pidgin->PurpleConversationDestroy($id);
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
