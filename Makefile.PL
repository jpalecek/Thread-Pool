require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;

WriteMakefile (
 NAME		=> "Thread::Pool",
 ($[ >= 5.005) ?
 (AUTHOR	=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
  ABSTRACT	=> 'group of threads for performing similar jobs') : (),
 VERSION_FROM	=> 'lib/Thread/Pool.pm',
 PREREQ_PM	=> {
                    'Thread::Queue::Any' => 0,
                    'Storable' => 0,
                   },
);