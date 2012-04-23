# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

my $loaded;

BEGIN { $| = 1; print "1..9\n"; }
END {print "not ok 1\n" unless $loaded;}
use strict;
use Getopt::Tabular;
$loaded = 1;
print "ok 1\n";
my $test_count = 1;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):


my $warning;
my $num_warnings = 0;

sub catch_warn 
{
   $warning = $_[0];
   $num_warnings++;
}

sub warning
{
   my $w = $warning;
   undef $warning;
   $w;
}

sub list_equal
{
   my ($eq, $a, $b) = @_;

   die "lequal: \$a and \$b not lists" 
      unless ref $a eq 'ARRAY' && ref $b eq 'ARRAY';

   return 0 unless @$a == @$b;          # compare lengths
   my @eq = map { &$eq ($a->[$_], $b->[$_]) } (0 .. $#$a);
   return 0 unless (grep ($_ == 1, @eq)) == @eq;
}

sub slist_equal
{
   my ($a, $b) = @_;
   list_equal (sub { $_[0] eq $_[1] }, $a, $b);
}

sub nlist_equal
{
   my ($a, $b) = @_;
   list_equal (sub { $_[0] == $_[1] }, $a, $b);
}

sub clear_values
{
   my ($types, $vals) = @_;
   my ($k, $t);

   foreach $k (keys %$types)
   {
      $t = $types->{$k};
      
      ($t =~ /^[bns]$/) and undef $vals->{$k};
      ($t =~ /^[ns]l$/) and @{$vals->{$k}} = ();
   }
}

sub values_equal
{
   my ($types, $a, $b) = @_;
   my ($k, $t);

#   return 0
#      unless slist_equal ([keys %$types], [keys %$a]) &&
#             slist_equal ([keys %$a], [keys %$b]);

   foreach $k (keys %$types)
   {
      $t = $types->{$k};
#      next unless exists $a->{$k} && exists $b->{$k};

      # first make sure that the defined-ness of $a->{$k} and $b->{$k}
      # are the same
      !(defined $a->{$k} xor defined $b->{$k}) || return 0;

      # now the type-dependent comparison
      ($t eq 'b') && (( !($a->{$k} xor $b->{$k}) || return 0), next);
      ($t eq 'n') && (($a->{$k} == $b->{$k} || return 0), next);
      ($t eq 's') && (($a->{$k} eq $b->{$k} || return 0), next);
      ($t eq 'nl') && ((nlist_equal ($a->{$k}, $b->{$k}) || return 0), next);
      ($t eq 'sl') && ((slist_equal ($a->{$k}, $b->{$k}) || return 0), next);
      die "unknown type \"$t\"";
   }

   return 1;
}

sub test
{
   my ($ok) = @_;

   printf "%s %d\n", ($ok ? "ok" : "not ok"), ++$test_count;
}

sub test_parse
{
   my ($opt_table, $args, $types, $values,
       $exp_leftovers, $exp_values, $exp_output, $exp_error) = @_;
   my ($k, $leftovers, $ok);

   $SIG{'__WARN__'} = \&catch_warn;

   clear_values ($types, $values);
   $leftovers = [];
   GetOptions ($opt_table, $args, $leftovers);

   delete $SIG{'__WARN__'};

   $ok = 1;
   unless (slist_equal ($leftovers, $exp_leftovers))
   {
      warn "leftovers don't match\n";
      $ok = 0;
   }
   unless (values_equal ($types, $values, $exp_values))
   {
      warn "values don't match\n";
      $ok = 0;
   }
   if ($exp_error && warning !~ /$exp_error/)
   {
      warn "warning message doesn't match\n";
      $ok = 0;
   }

   test ($ok);
}  # &test


my @foo = ();

sub get_foo
{
   my ($arg, $args) = @_;
   my $next;

#   print "Hello, you have used the $arg option\n";
   unless (@$args)
   {
      &Getopt::Tabular::SetError
         ("bad_foo", "no arguments found for $arg option");
      return 0;
   }

   while ($next = shift @$args)
   {
      last if $next =~ /^-/;
      push (@foo, $next);
#      print "Got $next from \@\$args\n";
   }

   if (defined $next)                   # not the last option?
   {
#      print "Putting $next back on \@\$args\n";
      unshift (@$args, $next);
   }
   1;
}



my %vals =
   (ints     => [],
    float    => undef,
    string   => undef,
    flag     => undef);
my %types = 
   (ints     => 'nl',
    float    => 'n',
    string   => 's',
    flag     => 'b');

    

my @opt_table = 
   (['-int',    'integer', 2, $vals{ints},
     'two integers', 'i1 i2'],
    ['-float',  'float',   1, \$vals{float},
     'a floating-point number' ],
    ['-string', 'string',  1, \$vals{string}, 
     'a string' ],
    ['-flag',   'boolean', 0, \$vals{flag},
     'a boolean flag' ],
    ['-foo',    'call',    0, \&get_foo,
     'do nothing important'],
    ['-show',   'eval',    0, 'print "Ints = @Ints\n";',
     'print the current values of -int option']
   );

# command line with no options: leftovers should be same as whole arg list
test_parse (\@opt_table,
            [qw(hello there)],
            \%types, \%vals,
            [qw(hello there)],
            { ints => [] }, '', '');

# with options, but no leftovers:
test_parse (\@opt_table, 
            [qw(-int 3 4 -string FOO!)],
            \%types, \%vals,
            [], 
            { ints => [3, 4], string => 'FOO!' },
            '', '');

# options and leftovers mixed up together
test_parse (\@opt_table, 
            [qw(hello -int 2 -5 there -string barf)],
            \%types, \%vals,
            [qw(hello there)], 
            { ints => [2, -5], string => 'barf' },
            '', '');

# similar, but add boolean option
test_parse (\@opt_table, 
            [qw(-flag how -int 2 -5 are you -string frab)],
            \%types, \%vals,
            [qw(how are you)], 
            { ints => [2, -5], string => 'frab', flag => 1 },
            '', '');

# now add callback option
test_parse (\@opt_table, 
            [qw(-flag how -int 2 -5 are you -foo x1 x2 -string frab)],
            \%types, \%vals,
            [qw(how are you)], 
            { ints => [2, -5], string => 'frab', flag => 1 },
            '', '');
test (slist_equal (\@foo, [qw(x1 x2)]));

# same, but with a negation of the boolean option later in the arg list
# and a different way of using the callback
test_parse (\@opt_table, 
            [qw(-flag bang -int 2 -5 pow! -noflag -foo bing bong bang)],
            \%types, \%vals,
            [qw(bang pow!)], 
            { ints => [2, -5], flag => 0 },
            '', '');
test (slist_equal (\@foo, [qw(x1 x2 bing bong bang)]));

# still need to test:
#   argument errors (ie. warnings)
#   table errors (catch `die')
#   custom patterns (eg. uppercase string)
#   spoof parsing
