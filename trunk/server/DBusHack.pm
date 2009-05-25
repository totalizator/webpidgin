package Net::DBus::RemoteObject;
# I don't like hacks, but I have no choise
no warnings;
sub connect_to_signal {
    my $self = shift;
    my $name = shift;
    my $code = shift;

    my $ins = $self->_introspector;
    my $interface = $self->{interface};
    if (!$interface) {
	if (!$ins) {
	    die "no introspection data available for '" . $self->get_object_path .
		"', and object is not cast to any interface";
	}
	my @interfaces = $ins->has_signal($name);

	if ($#interfaces == -1) {
	    die "no signal with name '$name' is exported in object '" .
		$self->get_object_path . "'\n";
	} elsif ($#interfaces > 0) {
	    warn "signal with name '$name' is exported " .
		"in multiple interfaces of '" . $self->get_object_path . "'" .
		"connecting to first interface only\n";
	}
	$interface = $interfaces[0];
    }

    if ($ins &&
	$ins->has_signal($name, $interface) &&
	$ins->is_signal_deprecated($name, $interface)) {
	warn "signal $name in interface $interface on " . $self->get_object_path . " is deprecated";
    }

    $self->get_service->
	get_bus()->
	_add_signal_receiver(sub {
	    my $signal = shift;
	    my $ins = $self->_introspector;
	    my @params;
	    if ($ins) {
		eval {
		    @params = $ins->decode($signal, "signals", $signal->get_member, "params");
		};
		@params = $signal->get_args_list if $@;
#		&$code(@params);
	    } else {
		@params = $signal->get_args_list;
	    }
	    &$code(@params);
	},
			     $name,
			     $interface,
			     $self->{service}->get_owner_name(),
			     $self->{object_path});
}
use warnings;
1;