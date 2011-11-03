use strict;
use Test::More;

use Data::Verifier;

{
    local $@ = undef;
    eval { Class::MOP::load_class('MooseX::Storage') };
    if ( defined $@ and $@ ) {
        plan skip_all => "Test not ran without MooseX::Storage: $@";
        exit;
    }
}

my $field = Data::Verifier::Field->new(
    reason => 'Testing purposes only',
    value  => 'Abracadabra',
    valid  => 1
);

ok($field->freeze({ format => 'Storable' }), 'frozen');

done_testing;
