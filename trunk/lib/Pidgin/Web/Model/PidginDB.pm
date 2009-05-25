package Pidgin::Web::Model::PidginDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Pidgin::Web::Schema',
    connect_info => [
        'dbi:mysql:webpidgin',
        'root',
        
    ],
);

=head1 NAME

Pidgin::Web::Model::PidginDB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<Pidgin::Web>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Pidgin::Web::Schema>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
