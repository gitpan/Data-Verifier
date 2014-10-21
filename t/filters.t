use strict;
use Test::Exception;
use Test::More;

use Data::Verifier;

{
    my $verifier = Data::Verifier->new(
        profile => {
            name => {
                filters => [ qw(collapse) ]
            },
            address1 => {
                filters => [ qw(trim) ]
            },
            address2 => {
                filters => [ qw(collapse trim) ]
            },
            foo => {
                filters => 'upper'
            },
            bar => {
                filters => 'lower'
            },
            baz => {
                filters => 'flatten'
            }
        }
    );

    my $results = $verifier->verify({
        name        => "foo\tbar",
        address1    => "  123 test  \n",
        address2    => "  123\n    test\t\n",
        foo         => 'Abc',
        bar         => 'Abc',
        baz         => 'asd asd   asdd   '
    });

    ok($results->success, 'success');
    cmp_ok($results->get_value('name'), 'eq', 'foo bar', 'collapse');
    cmp_ok($results->get_original_value('name'), 'eq', "foo\tbar", 'original_value');
    cmp_ok($results->get_post_filter_value('name'), 'eq', "foo bar", 'post_filter_value');
    cmp_ok($results->get_value('address1'), 'eq', '123 test', 'trim');
    cmp_ok($results->get_value('address2'), 'eq', '123 test', 'trim + collapse');
    cmp_ok($results->get_value('foo'), 'eq', 'ABC', 'upper');
    cmp_ok($results->get_value('bar'), 'eq', 'abc', 'lower');
    cmp_ok($results->get_value('baz'), 'eq', 'asdasdasdd', 'flatten');
}

{
    my $verifier = Data::Verifier->new(
        filters => [ qw(upper) ],
        profile => {
            name => {
                required => 1
            },
        }
    );

    my $results = $verifier->verify({
        name        => "foo bar",
    });

    ok($results->success, 'success');
    cmp_ok($results->get_value('name'), 'eq', 'FOO BAR', 'collapse');
}

{
    my $sub = sub { my ($val) = @_; $val =~ s/\s//g; $val; };
    my $verifier = Data::Verifier->new(
        filters => [ $sub ],
        profile => {
            name => {
                required => 1
            },
        }
    );

    my $results = $verifier->verify({
        name        => "foo bar",
    });

    ok($results->success, 'success');
    cmp_ok($results->get_value('name'), 'eq', 'foobar', 'custom filer');
}

{
    my $verifier = Data::Verifier->new(
        filters => [ qw(foobazgorch) ],
        profile => {
            name => {
                required => 1
            },
        }
    );

    throws_ok { $verifier->verify({ name        => "foo bar" }) }
        qr/Unknown filter: foobazgorch/, 'unknown filter';
}


done_testing;