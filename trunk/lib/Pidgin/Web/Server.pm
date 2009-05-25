package Pidgin::Web::Server;
use strict;
use Data::Dumper;
use XML::Simple;
use DBusHack;
use Sys::Syslog;
our $AUTOLOAD;
use Data::Dumper;
sub WroteImMsg{
    my $data={
        method=>'WroteImMsg',
        params=>\@_
    };
    $_[1]=sprintf '<font color="%s">(%s) <b>%s</b>:</font>',($_[4]==2?'#ff0000':'#0000ff'),(join ":",(localtime)[2,1,0]),($_[4]==2?$XMLServer::pidgin->PurpleBuddyGetAliasOnly($XMLServer::pidgin->PurpleFindBuddy(@_[0,1])):$XMLServer::pidgin->PurpleAccountGetAlias($_[0])),$_[2];
    _output($data);
#    $XMLServer::select->add( $XMLServer::client);
    
}
sub WroteChatMsg{
    my $data={
        method=>'WroteImMsg',
        params=>\@_
    };
    if ($_[2]!~m|^/me |){
    $_[1]=sprintf '<font color="%s">(%s) <b>%s</b>:</font>',($_[4]==2?'#ff0000':'#0000ff'),(join ":",(localtime)[2,1,0]),$_[1];
    } else {
    $_[1]=sprintf '<font color="%s">(%s) *** %s </font>',($_[4]==2?'#ff0000':'#0000ff'),(join ":",(localtime)[2,1,0]),$_[1];
    $_[2]=~s|^/me ||;
    }
    _output($data);
#    $XMLServer::select->add( $XMLServer::client);
    
}
sub ConversationCreated{
    my $data={
	method=>'ConversationCreated',
	params=>\@_
    };
    push @_,$XMLServer::pidgin->PurpleConversationGetTitle($_[0]);
    my $im = $XMLServer::pidgin->PurpleConversationGetImData($_[0]);
    push @_, $im;
    if ($im && (my $icon = $XMLServer::pidgin->PurpleConvImGetIcon($im))){
        my $iconpath = $XMLServer::pidgin->PurpleBuddyIconGetFullPath($icon);
        $iconpath =~s/.*\///;
	push @_, $iconpath;

    }
    _output($data);
}
sub DisplayingUserinfo{
    my $data={
	method=>'DisplayingUserInfo',
	params=>\@_
    };
#    $_[2].='x';
#    push @_, $XMLServer::pidgin->PurpleNotifyUserInfoGetTextWithNewline($_[2], "<BR>");

#    my $im = $XMLServer::pidgin->PurpleConversationGetImData($_[0]);
    _output($data);
}
sub BuddyStatusChanged{
        my %icons=(
                offline=>'IconStatus22Offline',
                available=>'IconStatus22Available',
                away=>'IconStatus22Away',
                dnd=>'IconStatus22Busy',
                na=>'IconStatus22Away',
                invisible=>'IconStatus22Invisible',
                occupied=>'IconStatus22Busy',
                '???'=>'IconStatus22ExtendedAway',
        );

	my $data={
		method=>'BuddyStatusChanged',
		params=>\@_
	};
	return if $_[1]==$_[2];
	$_[1]=$_[2];
        $_[2]=$XMLServer::pidgin->PurpleStatusGetId($_[1]);
        $_[3]=$icons{$XMLServer::pidgin->PurpleStatusGetId($_[1])};
    _output($data);
}
our %fhs;
sub _output{
    my $data=shift;
    syslog 'info', (XMLout($data,RootName=>'Signal'));

    foreach (@main::clients){
	local $/=undef;
	local $\=undef;
	open ($fhs{$$_}, "<&=$$_") unless $fhs{$$_};
	chomp(my $data=XMLout($data,RootName=>'Signal'));
	eval {
    	syswrite $fhs{$$_}, ($data."\x00") or die $!;
	};
	if ($@){
	    delete $fhs{$$_};
	}
    }

}
sub AUTOLOAD{
    (my $method=$AUTOLOAD)=~s/(.*):://;
    my $data={
	method=>$method,
	params=>\@_
    };
    _output($data);
#    $XMLServer::select->add( $XMLServer::client);
}

1;
