package Catalyst;
use Time::HiRes qw/sleep/;
sub dbus_lock{
#    my $self=shift;
#    sleep(0.1) while ($self->cache->get('dbus_lock'));
#    $self->cache->set('dbus_lock'=>1,10);
}

sub remove_lock{
    my $self=shift;
    $self->cache->delete('dbus_lock');
}
1;