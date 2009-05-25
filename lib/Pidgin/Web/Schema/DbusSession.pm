package Pidgin::Web::Schema::DbusSession;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-07-01 02:28:17

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("dbus_session");
__PACKAGE__->add_columns(
  "user",
  { data_type => "BIGINT", default_value => "", is_nullable => 0, size => 20 },
  "session",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 100,
  },
  "pid",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("user");

1;

