package Pidgin::Web::Schema::Users;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-07-01 02:28:17

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "password",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 60,
  },
);
__PACKAGE__->has_one(dbus_session=>"Pidgin::Web::Schema::DbusSession");
__PACKAGE__->set_primary_key("id");

1;

