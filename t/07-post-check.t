use strict;
use Test::More;

use Data::Verifier;

{
    my $verifier = Data::Verifier->new(
        profile => {
            password    => {
                required => 1,
                post_check => sub {
                    my $r = shift;
                    return 0 if !$r->is_valid('password2');
                    return $r->get_value('password') eq $r->get_value('password2');
                }
            },
            password2   => {
                required => 1
            }
        }
    );

    my $results = $verifier->verify({ password => 'foo', password2 => 'foo' });

    ok($results->success, 'success');
    cmp_ok($results->valid_count, '==', 2, '2 valid');
    cmp_ok($results->invalid_count, '==', 0, 'none invalid');
    cmp_ok($results->missing_count, '==', 0, 'none missing');
    ok($results->is_valid('password'), 'password is valid');
    ok($results->is_valid('password2'), 'password2 is valid');
    cmp_ok($results->get_value('password'), 'eq', 'foo', 'get_value password');
    cmp_ok($results->get_value('password2'), 'eq', 'foo', 'get_value password2');
}

{
    my $verifier = Data::Verifier->new(
        profile => {
            email    => {
                required => 1,
                dependent => {
                    email2 => {
                        required => 1,
                    }
                },
                post_check => sub {
                    my $r = shift;
                    return $r->get_value('email') eq $r->get_value('email2');
                }
            },
        }
    );

    my $results = $verifier->verify({ email => 'foo', email2 => 'foo2' });

    ok(!$results->success, 'failed');
    cmp_ok($results->valid_count, '==', 1, '1 valid');
    cmp_ok($results->invalid_count, '==', 1, '1 invalid');
    cmp_ok($results->missing_count, '==', 0, 'none missing');
    ok($results->is_invalid('email'), 'email is invalid');
    ok($results->is_valid('email2'), 'email2 is valid');
}


done_testing;