BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use threads qw(yield);
use strict;
use Test::More tests => 18;

BEGIN { use_ok('Thread::Pool') }

my $check = '';
my $times = 1000;
my $format = '%5d';
my $t = 10;
my @list : shared = (0);

my $pool = Thread::Pool->new( {workers => $t,qw(do do stream stream)} );
isa_ok( $pool,'Thread::Pool',		'check object type' );
cmp_ok( scalar($pool->workers),'==',$t,	'check initial number of workers' );

foreach ( 1..$times ) {
  $pool->job( $_ );
  $check .= sprintf( $format,$_ );
}

$pool->shutdown;
cmp_ok( scalar(threads->list),'==',0,	'check for remaining threads, #1' );
cmp_ok( scalar($pool->workers),'==',0,	'check number of workers, #1' );
cmp_ok( scalar($pool->removed),'==',$t, 'check number of removed, #1' );
cmp_ok( $pool->todo,'==',0,		'check # jobs todo, #1' );
cmp_ok( $pool->done,'==',$times,	'check # jobs done, #1' );

my $notused = $pool->notused;
ok( $notused >= 0 and $notused < $t,	'check not-used threads, #1' );

my $failed = 0;
foreach (1..$times) {
    next if $_ == $list[$_];
    fail( "Check failed on iteration $_, value = $list[$_]" );
    $failed = 1;
    last;
}
pass( "Check succeeded" ) unless $failed;
#is( join('',@list),$check,		'check first result' );

$pool->job( $_ ) foreach 1..$times;

$pool->workers( $t+$t);
cmp_ok( scalar($pool->workers),'==',$t+$t, 'check number of workers, #2' );

$pool->shutdown;
cmp_ok( scalar(threads->list),'==',0,	'check for remaining threads, #2' );
cmp_ok( scalar($pool->workers),'==',0,	'check number of workers, #2' );
cmp_ok( scalar($pool->removed),'==',$t+$t+$t, 'check number of removed, #2' );
cmp_ok( $pool->todo,'==',0,		'check # jobs todo, #2' );
cmp_ok( $pool->done,'==',$times+$times,	'check # jobs done, #2' );

my $notused = $pool->notused;
ok( $notused >= 0 and $notused < $t+$t+$t, 'check not-used threads, #2' );

$failed = 0;
foreach (1..$times) {
    next if $_ == $list[$times+$_];
    warn "Check failed on iteration ".($times+$_).", value = $list[$times+$_],$list[$times+$_+1]!";
    fail( "Check failed on iteration ".($times+$_).", value = $list[$times+$_],$list[$times+$_+1]!" );
    $failed = 1;
    last;
}
pass( "Check succeeded" ) unless $failed;
#is( join('',@list),$check.$check,	'check second result' );

sleep( 2 ); # just make sure no detached threads still running

sub do { yield(); sprintf( $format,$_[1] ) }

sub stream { lock( @list ); push( @list,$_[1] ) }