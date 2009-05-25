package Pidgin::Web::Schema::Sessions;

# Created by DBIx::Class::Schema::Loader v0.03009 @ 2007-07-01 02:28:17

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("sessions");
__PACKAGE__->add_columns(
  "id",
  { data_type => "CHAR", default_value => "", is_nullable => 0, size => 72 },
  "session_data",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "expires",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");

1;

