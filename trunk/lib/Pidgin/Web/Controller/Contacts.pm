package Pidgin::Web::Controller::Contacts;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use XML::Simple;

=head1 NAME

Pidgin::Web::Controller::Contacts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Pidgin::Web::Controller::Contacts in Contacts.');
}

sub info :Local{
    my ($self,$c) = @_;
    my $pidgin=$c->config->{pidgin};
    my $id = $c->req->param('id');
    $pidgin->ServGetInfo($pidgin->PurpleAccountGetConnection($pidgin->PurpleBuddyGetAccount($id)),$pidgin->PurpleBuddyGetName($id));
    $c->res->body('1');
}

sub list :Local{
	my ($self,$c) = @_;
	my @contacts;
    my $pidgin=$c->config->{pidgin};
	if (my $contacts=$c->cache->get('contacts_'.$c->user->id)){
	    $c->res->body(XMLout($contacts));
	    return;
	};

	my %prevcontacts=%{$c->cache->get('prevcontacts')||{}} if $c->req->param('old');
	my %icons=(
		offline=>'IconStatus22Offline',
		available=>'IconStatus22Available',
		free4chat=>'IconStatus22Available',
		away=>'IconStatus22Away',
		dnd=>'IconStatus22Busy',
		na=>'IconStatus22Away',
		invisible=>'IconStatus22Invisible',
		occupied=>'IconStatus22Busy',
		'???'=>'IconStatus22ExtendedAway',
	);

	my @protocols;
	my $output;
	my $timeout=60;
		my $blist=$pidgin->PurpleGetBlist();
		warn "PurpleGetBlist";
		my $node=$pidgin->PurpleBlistGetRoot();
		warn "PurpleBlistGetRoot";
		while ($node){
			my $item={};
			$item->{id}=$node;
			if ($pidgin->PurpleBlistNodeIsGroup($node)){
				next unless ($pidgin->PurplePrefsGetBool($c->config->{prefs}.'/contacts/showgroups'));
				$item->{contact_type}='group';
				$item->{label}=$pidgin->PurpleGroupGetName($node);
				$item->{online}=$pidgin->PurpleBlistGetGroupOnlineCount($node);
				$item->{offline}=$pidgin->PurpleBlistGetGroupSize($node,0);
				$item->{contacts}=[];
				push @contacts,$item;
			} elsif ($pidgin->PurpleBlistNodeIsBuddy($node)){
				$item->{contact_type}='buddy';
				unless ($pidgin->PurplePrefsGetBool($c->config->{prefs}.'/contacts/showoffline') || 
					$pidgin->PurpleBuddyIsOnline($node)){
					next;
				}
				$item->{name}=$pidgin->PurpleBuddyGetName($node);				
				$item->{label}=$pidgin->PurpleBuddyGetAlias($node);
				$item->{icon}=$pidgin->PurpleBuddyGetIcon($node);
				if ($item->{id} && (my $icon = $pidgin->PurpleBuddyGetIcon($item->{id}))){
				    $item->{avatar} = $pidgin->PurpleBuddyIconGetFullPath($icon);
				    $item->{avatar} =~s/.*\///;
				}
#				$item->{server}=$pidgin->PurpleBuddyGetServerAlias($node);
#				$pidgin->ServGetInfo($pidgin->PurpleAccountGetConnection($pidgin->PurpleBuddyGetAccount($node)),$item->{name});
#				unless ($pidgin->PurpleBuddyGetServerAlias($node)){
#				    $pidgin->ServAliasBuddy($node);
#				} else {
#				}
				$item->{account}=$pidgin->PurpleBuddyGetAccount($node);
				$item->{type}=$pidgin->PurpleAccountGetProtocolName($item->{account});
				$item->{presence}=$pidgin->PurpleBuddyGetPresence($node);
				$item->{status}=$pidgin->PurplePresenceGetActiveStatus($item->{presence});
				$item->{status_name}=$pidgin->PurpleStatusGetId($item->{status});
				$item->{icon}=$icons{$item->{status_name}};
				if ($pidgin->PurplePrefsGetBool($c->config->{prefs}.'/contacts/showgroups')){
				    foreach (@contacts){
					unshift @{$_->{contacts}}, $item if $_->{id}==$pidgin->PurpleBuddyGetGroup($item->{id});
				    }
				} else {
				    push @contacts,$item;
				}
			} elsif ($pidgin->PurpleBlistNodeIsChat($node)){
				$item->{contact_type}='chat';
				$item->{label}=$pidgin->PurpleChatGetName($node);
				$item->{account}=$pidgin->PurpleChatGetAccount($node);
				$item->{type}=$pidgin->PurpleAccountGetProtocolName($item->{account});
				$item->{icon}='IconStatus22Chat';
				if ($pidgin->PurplePrefsGetBool($c->config->{prefs}.'/contacts/showgroups')){
				    foreach (@contacts){
					unshift @{$_->{contacts}}, $item if $_->{id}==$pidgin->PurpleChatGetGroup($item->{id});
				    }
				} else {
				    push @contacts,$item;
				}
			}	
		} continue{
		    $node=$pidgin->PurpleBlistNodeNext($node,0)
		};
		warn "preved";
		$c->log->info('preved');
		if (! $pidgin->PurplePrefsGetBool($c->config->{prefs}.'/contacts/showemptygroups') && $pidgin->PurplePrefsGetBool($c->config->{prefs}.'/contacts/showgroups')){
			for (my $i=0;$i<@contacts;$i++){
				unless (@{$contacts[$i]->{contacts}}){
					splice @contacts,$i,1;
					$i--; 
				}
			}
		}
		$c->cache->set('contacts_'.$c->user->id=>\@contacts,1);
		$output=XMLout(\@contacts);
		%prevcontacts=();
		%prevcontacts=map {$_->{id}=>$_} @contacts;
    		$c->res->body($output);
}
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

GET /contacts/list HTTP/1.1
Host: gugu-laptop:3001
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.3) Gecko/20061201 Firefox/2.0.0.3 (Ubuntu-feisty)
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: ru-ru,ru;q=0.8,en-us;q=0.5,en;q=0.3
Accept-Encoding: gzip,deflate
Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.7
Keep-Alive: 300
Connection: keep-alive



=cut

1;
