package Pidgin::Web;

use strict;
use warnings;
use Net::DBus;
use Catalyst::Runtime '5.70';
our $VERSION = '0.01';
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory
use Pidgin::Web::DBus;
use Catalyst qw/
	-Debug 
	ConfigLoader 
	Session
	Session::Store::DBIC
	Session::State::Cookie
	Static::Simple
	Cache::Memcached
	Authentication
        Authentication::Store::DBIC
	Authentication::Credential::Password

/;

our $VERSION = '0.01';

# Configure the application. 
#
# Note that settings in Pidgin::Web.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name => 'Pidgin::Web' );
# Connecting to D-Bus
__PACKAGE__->config( prefs => '/webpidgin' );
__PACKAGE__->config( session => {
    dbic_class=> 'Pidgin::Web::Model::PidginDB::Sessions',
    expires=> 3600*24*30
 });
__PACKAGE__->config(
    authentication=>{
	dbic=>{
	    password_field=>'password',
	    password_hash_type=>'SHA-1',
	    password_type=>'hashed',
	    user_class=>'Pidgin::Web::Model::PidginDB::Users',
	    user_field=>'email'
	}
    }
);
__PACKAGE__->config->{cache}->{servers} = [ '127.0.0.1:11211' ];
# Start the application
__PACKAGE__->setup;

=head1 NAME

Pidgin::Web - Catalyst based application

=head1 SYNOPSIS

    script/pidgin_web_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Pidgin::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Andrey (GuGu) Kostenko

=head1 LICENSE


GNU GPLv2

=cut

1;
