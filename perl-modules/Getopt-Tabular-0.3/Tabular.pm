package Getopt::Tabular;

#
# Getopt/Tabular.pm
#
# Perl module for table-driven argument parsing, somewhat like Tk's
# ParseArgv.  To use the package, you just have to set up an argument table
# (a list of array references), and call &GetOptions (the name is exported
# from the module).  &GetOptions takes two or three arguments; a reference
# to your argument table (which is not modified), a reference to the list
# of command line arguments, e.g. @ARGV (or a copy of it), and (optionally)
# a reference to a new empty array.  In the two argument form, the second
# argument is modified in place to remove all options and their arguments.
# In the three argument form, the second argument is unmodified, and the
# third argument is set to a copy of it with options removed.
#
# The argument table consists of one element per valid command-line option;
# each element should be a reference to a list of the form:
#
#    ( option_name, type, num_values, option_data, help_string, arg_desc )
#
# See Getopt/Tabular.pod for complete information.
# 
# originally by Greg Ward 1995/07/06-07/09 as ParseArgs.pm
# renamed to Getopt::Tabular and somewhat reorganized/reworked,
# 1996/11/08-11/10
#
# $Id: Tabular.pm,v 1.8 1999/04/08 01:11:24 greg Exp $

# Copyright (c) 1995-98 Greg Ward. All rights reserved.  This package is
# free software; you can redistribute it and/or modify it under the same
# terms as Perl itself.

require Exporter;
use Carp;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use vars qw/%Patterns %OptionHandlers %TypeDescriptions @OptionPatterns
            %SpoofCode $OptionTerminator $HelpOption
            $LongHelp $Usage $ErrorClass $ErrorMessage/;

$VERSION = 0.3;
@ISA = qw/Exporter/;
@EXPORT = qw/GetOptions/;
@EXPORT_OK = qw/SetHelp SetHelpOption SetError GetError SpoofGetOptions/;

# -------------------------------------------------------------------- #
# Private global variables                                             #
# -------------------------------------------------------------------- #


# The regexp for floating point numbers here is a little more permissive
# than the C standard -- it recognizes "0", "0.", ".0", and "0.0" (where 0
# can be substituted by any string of one or more digits), preceded by an
# optional sign, and followed by an optional exponent.

%Patterns = ('integer' => '[+-]?\d+',
             'float'   => '[+-]? ( \d+(\.\d*)? | \.\d+ ) ([Ee][+-]?\d+)?',
             'string'  => '.*');


# This hash defines the allowable option types, and what to do when we 
# see an argument of a given type in the argument list.  New types
# can be added by calling AddType, as long as you supply an option 
# handler that acts like one of the existing handlers.  (Ie. takes
# the same three arguments, returns 1 for success and 0 for failure,
# and calls SetError appropriately.)

%OptionHandlers = ("string",    \&process_pattern_option, 
                   "integer",   \&process_pattern_option, 
                   "float",     \&process_pattern_option, 
                   "boolean",   \&process_boolean_option, 
                   "const",     \&process_constant_option, 
                   "copy",      \&process_constant_option, 
                   "arrayconst",\&process_constant_option, 
                   "hashconst", \&process_constant_option, 
                   "call",      \&process_call_option, 
                   "eval",      \&process_eval_option, 
                   "section",   undef);

# This hash is used for building error messages for pattern types.  A 
# subtle point is that the description should be such that it can be 
# pluralized by adding an "s".  OK, OK, you can supply an alternate
# plural form by making the description a reference to a two-element list,
# singular and plural forms.  I18N fanatics should be happy.

%TypeDescriptions = ("integer" => "integer", 
                     "float"   => "floating-point number",
                     "string"  => "string");

@OptionPatterns = ('(-)(\w+)');        # two parts: "prefix" and "body"
$OptionTerminator = "--";
$HelpOption = "-help";

# The %SpoofCode hash is for storing alternate versions of callbacks
# for call or eval options.  The alternate versions should have no side
# effects apart from changing the argument list identically to their
# "real" alternatives.

%SpoofCode = ();

$ErrorClass = "";                       # can be "bad_option", "bad_value",
                                        # "bad_eval", or "help"
$ErrorMessage = "";                     # can be anything

# -------------------------------------------------------------------- #
# Public (but not exported) subroutines used to set options before     #
# calling GetOptions.                                                  #
# -------------------------------------------------------------------- #

sub SetHelp
{
   $LongHelp = shift;
   $Usage = shift;
}

sub SetOptionPatterns
{
   @OptionPatterns = @_;
}

sub SetHelpOption
{
   $HelpOption = shift;
}

sub SetTerminator
{
   $OptionTerminator = shift;
}

sub UnsetTerminator
{
   undef $OptionTerminator;
}

sub AddType
{
   my ($type, $handler) = @_;
   croak "AddType: \$handler must be a code ref"
      unless ref $handler eq 'CODE';
   $OptionHandlers{$type} = $handler;
}

sub AddPatternType
{
   my ($type, $pattern, $description) = @_;
   $OptionHandlers{$type} = \&process_pattern_option;
   $Patterns{$type} = $pattern;
   $TypeDescriptions{$type} = ($description || $type);
}

sub GetPattern
{
   my ($type) = @_;
   $Patterns{$type};
}

sub SetSpoofCodes
{
   my ($option, $code);
   croak "Even number of arguments required" 
      unless (@_ > 0 && @_ % 2 == 0);

   while (@_)
   {
      ($option, $code) = (shift, shift);
      $SpoofCode{$option} = $code;
   }
}

sub SetError
{
   $ErrorClass = shift;
   $ErrorMessage = shift;
}

sub GetError
{
   ($ErrorClass, $ErrorMessage);
}

# --------------------------------------------------------------------
# Private utility subroutines:
#   quote_strings
#   print_help
#   scan_table
#   match_abbreviation
#   option_error
#   check_value
#   split_option
#   find_calling_package
# --------------------------------------------------------------------


# 
# &quote_strings
#
# prepares strings for printing in a list of default values (for the 
# help text).  If a string is empty or contains whitespace, it is quoted;
# otherwise, it is left alone.  The input list of strings is returned 
# concatenated into a single space-separated string.  This is *not*
# rigorous by any stretch; it's just to make the help text look nice.
#
sub quote_strings
{
   my @strings = @_;
   my $string;
   foreach $string (@strings)
   {
      $string = qq["$string"] if ($string eq '' || $string =~ /\s/);
   }
   return join (' ', @strings);
}


#
# &print_help
#
# walks through an argument table and prints out nicely-formatted
# option help for all entries that provide it.  Also does the Right Thing
# (trust me) if you supply "argument description" text after the help.
#
# Don't read this code if you can possibly avoid it.  It's pretty gross.
#
sub print_help
{
   confess ("internal error, wrong number of input args to &print_help")
      if (scalar (@_) != 1);
   my ($argtable) = @_;
   my ($maxoption, $maxargdesc, $numcols, $opt, $breakers);
   my ($textlength, $std_format, $alt_format);
   my ($option, $type, $num, $value, $help, $argdesc);

   $maxoption = 0;
   $maxargdesc = 0;

   # Loop over all options to determine the length of the longest option name
   foreach $opt (@$argtable)
   {
      my ($argdesclen, $neg_option);
      my ($option, $type, $help, $argdesc) = @{$opt} [0,1,4,5];
      next if $type eq "section" or ! defined $help;

      # Boolean options contribute *two* lines to the help: one for the
      # option, and one for its negative.  Other options just contribute
      # one line, so they're a bit simpler.
      if ($type eq 'boolean')
      {
         my ($pos, $neg) = &split_option ($opt);
         my $pos_len = length ($pos);
         my $neg_len = length ($neg);
         $maxoption = $pos_len if ($pos_len > $maxoption);
         $maxoption = $neg_len if ($pos_len > $maxoption);
         carp "Getopt::Tabular: argument descriptions ignored " .
              "for boolean option \"$option\""
            if defined $argdesc;
      }
      else
      {
         my $optlen = length ($option);
         $maxoption = $optlen if ($optlen > $maxoption);

         if (defined $argdesc)
         {
            $argdesclen = length ($argdesc);
            $maxargdesc = $argdesclen if ($argdesclen > $maxargdesc);
         }
      }
   }

   # We need to construct and eval code that looks something like this:
   #    format STANDARD =
   #    @<<<<<<<<<<<<<<<  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   # $option,        $help
   # ~~                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   #                 $help
   # .
   # 
   # with an alternative format like this:
   #    format ALTERNATIVE = 
   #    @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   # $option, $argdesc
   #                      ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   #                 $help
   # ~~                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   #                 $help
   # .
   # in order to nicely print out the help.  Can't hardcode a format, 
   # though, because we don't know until now how much space to allocate
   # for the option (ie. $maxoption).

   local $: = " \n";
   local $~;

   $numcols = 80;                       # not always accurate, but faster!

   # width of text = width of terminal, with columns removed as follows:
   # 3 (for left margin), $maxoption (option names), 2 (gutter between
   # option names and help text), and 2 (right margin)
   $textlength = $numcols - 3 - $maxoption - 2 - 2;
   $std_format = "format STANDARD =\n" .
      "   @" . ("<" x $maxoption) . " ^" . ("<" x ($textlength-1)) . "\n".
      "\$option, \$help\n" .
      "~~  " . (" " x $maxoption) . " ^" . ("<" x ($textlength-1)) . "\n" .
      "\$help\n.";
   $alt_format = "format ALTERNATIVE =\n" .
      "   @" . ("<" x ($maxoption + $maxargdesc)) . "\n" .
      "\$option\n" .
      "   " . (" " x $maxoption) . "  ^" . ("<" x ($textlength-1)) . "\n" .
      "\$help\n" .
      "~~ " . (" " x $maxoption) . "  ^" . ("<" x ($textlength-1)) . "\n" .
      "\$help\n.";
      
   eval $std_format;
   confess ("internal error with format \"$std_format\": $@") if $@;
   eval $alt_format;
   confess ("internal error with format \"$alt_format\": $@") if $@;

   my $show_defaults = 1;

   print $LongHelp . "\n" if defined $LongHelp;
   print "Summary of options:\n";
   foreach $opt (@$argtable)
   {
      ($option, $type, $num, $value, $help, $argdesc) = @$opt;

      if ($type eq "section")
      {
	 printf "\n-- %s %s\n", $option, "-" x ($numcols-4-length($option));
         next;
      }

      next unless defined $help;
      $argdesc = "" unless defined $argdesc;

      my $show_default = $show_defaults && $help !~ /\[default/;

      $~ = 'STANDARD';
      if ($type eq 'boolean')
      {
         undef $option;                 # arg! why is this necessary?
         my ($pos, $neg) = &split_option ($opt);
         $option = $pos;
         $help .= ' [default]'
            if $show_default && defined $$value && $$value;
         write;
         $help = "opposite of $pos";
         $help .= ' [default]' 
            if $show_default && defined $$value && ! $$value;
         $option = $neg;
         write;
      }
      else
      {
         # If the option type is of the argument-taking variety, then
         # we'll try to help out by saying what the default value(s)
         # is/are
         if ($OptionHandlers{$type} == \&process_pattern_option)
         {
            if ($num == 1)              # expectes a scalar value
            {
               $help .= ' [default: ' . quote_strings ($$value) . ']'
                  if ($show_default && defined $$value);                  
            }
            else                        # expects a vector value
            {
               $help .= ' [default: ' . quote_strings (@$value) . ']'
                  if ($show_default && 
                      @$value && ! grep (! defined $_, @$value));
            }
         }

         if ($argdesc)
         {
            my $expanded_option = $option . " " . $argdesc if $argdesc;
            $option = $expanded_option;

            if (length ($expanded_option) > $maxoption+1)
            {
               $~ = 'ALTERNATIVE';
            }
         }         
         write;
      }
   }

   print "\n";
   print $Usage if defined $Usage;
}


#
# &scan_table
#
# walks through an argument table, building a hash that lets us quickly
# and painlessly look up an option.
#
sub scan_table
{
   my ($argtable, $arghash) = @_;
   my ($opt, $option, $type, $value);

   my $i;
   for $i (0 .. $#$argtable)
   {
      $opt = $argtable->[$i];
      ($option, $type, $value) = @$opt;
      unless (exists $OptionHandlers{$type})
      {
	 croak "Unknown option type \"$type\" supplied for option $option";
      }

      if ($type eq "boolean")
      {
         my ($pos,$neg) = &split_option($opt);
	 $arghash->{$pos} = $i;
         $arghash->{$neg} = $i if defined $neg;
      }
      elsif ($type ne "section")
      {
	 $arghash->{$option} = $i;
      }
   }
}


#
# &match_abbreviation
# 
# Given a string $s and a list of words @$words, finds the word for which
# $s is a non-ambiguous abbreviation.  If $s is found to be ambiguous or
# doesn't match, a clear and concise error message is printed, using
# $err_format as a format for sprintf.  Suggested form for $err_format is
# "%s option: %s"; the first %s will be substituted with either "ambiguous"
# or "unknown" (depending on the problem), and the second will be
# substituted with $s.  Thus, with this format, the error message will look
# something like "unknown option: -foo" or "ambiguous option: -f".
#
sub match_abbreviation
{
   my ($s, $words, $err_format) = @_;
   my ($match);

   my $word;
   foreach $word (@$words)
   {
      # If $s is a prefix of $word, it's at least an approximate match,
      # so try to do better

      next unless ($s eq substr ($word, 0, length ($s)));

      # We have an exact match, so return it now

      return $word if ($s eq $word);

      # We have an approx. match, and already had one before

      if ($match)
      {				
         &SetError ("bad_option", sprintf ("$err_format", "ambiguous", $s));
	 return 0;
      }

      $match = $word;
   }
   &SetError ("bad_option", sprintf ("$err_format", "unknown", $s)) 
      if !$match;
   $match;
}


#
# &option_error
# 
# Constructs a useful error message to deal with an option that expects
# a certain number of values of certain types, but a command-line that
# falls short of this mark.  $option should be the option that triggers
# the situation; $type should be the expected type; $n should be the
# number of values expected.
#
# The error message (returned by the function) will look something like
# "-foo option must be followed by an integer" (yes, it does pick "a"
# or "an", depending on whether the description of the type starts
# with a vowel) or "-bar option must be followed by 3 strings".
#
# The error message is put in the global $ErrorMessage, as well as returned
# by the function.  Also, the global $ErrorClass is set to "bad_value".
#
sub option_error
{   
   my ($option, $type, $n) = @_;
   my ($typedesc, $singular, $plural, $article, $desc);

   $typedesc = $TypeDescriptions{$type};
   ($singular,$plural) = (ref $typedesc eq 'ARRAY')
      ? @$typedesc 
      : ($typedesc, $typedesc . "s");

   $article = ($typedesc =~ /^[aeiou]/) ? "an" : "a";
   $desc = ($n > 1) ? 
      "$n $plural" : 
      "$article $singular";
   &SetError ("bad_value", "$option option must be followed by $desc");
}
   

#
# &check_value
#
# Verifies that a value (presumably from the command line) satisfies
# the requirements for the expected type.
#
# Calls &option_error (to set $ErrorClass and $ErrorMessage globals) and returns
# 0 if the value isn't up to scratch.
#
sub check_value
{
   my ($val, $option, $type, $n) = @_;

   unless (defined $val && $val =~ /^$Patterns{$type}$/x)
   {
      &option_error ($option, $type, $n);
      return 0;
   }      
}


# 
# &split_option
#
# Splits a boolean option into positive and negative alternatives.  The 
# two alternatives are returned as a two-element array.
# 
# Croaks if it can't figure out the alternatives, or if there appear to be
# more than 2 alternatives specified.
#
sub split_option
{
   my ($opt_desc) = @_;
   my ($option, @options);

   $option = $opt_desc->[0];
   return ($option) if $opt_desc->[1] ne "boolean";

   @options = split ('\|', $option);

   if (@options == 2)
   {
      return @options;
   }
   elsif (@options == 1)
   {
      my ($pattern, $prefix, $positive_alt, $negative_alt);
      for $pattern (@OptionPatterns)
      {
         my ($prefix, $body);
         if (($prefix, $body) = $option =~ /^$pattern$/)
         {
            $negative_alt = $prefix . "no" . $body;
            return ($option, $negative_alt);
         }
      }
      croak "Boolean option \"$option\" did not match " .
         "any option prefixes - unable to guess negative alternative";
      return ($option);
   }
   else
   {
      croak "Too many alternatives supplied for boolean option \"$option\"";
   }
}


# 
# &find_calling_package
# 
# walks up the call stack until we find a caller in a different package
# from the current one.  (Handy for `eval' options, when we want to 
# eval a chunk of code in the package that called GetOptions.)
# 
sub find_calling_package
{
   my ($i, $this_pkg, $up_pkg, @caller);
   
   $i = 0;
   $this_pkg = (caller(0))[0];
   while (@caller = caller($i++))
   {
      $up_pkg = $caller[0];
      last if $up_pkg ne $this_pkg;
   }
   $up_pkg;
}


# ----------------------------------------------------------------------
# Option-handling routines:
#   process_constant_option
#   process_boolean_option
#   process_call_option
#   process_eval_option
# ----------------------------------------------------------------------

# General description of these routines: 
#   * each one is passed exactly four options:
#       $arg      - the argument that triggered this routine, expanded
#                   into unabbreviated form
#       $arglist  - reference to list containing rest of command line
#       $opt_desc - reference to an option descriptor list
#       $spoof    - flag: if true, then no side effects
#   * they are called from GetOptions, through code references in the
#     %OptionHandlers hash
#   * if they return a false value, then GetOptions immediately returns
#     0 to its caller, with no error message -- thus, the option handlers
#     should print out enough of an error message for the end user to
#     figure out what went wrong; also, the option handlers should be
#     careful to explicitly return 1 if everything went well!

sub process_constant_option
{
   my ($arg, $arglist, $opt_desc, $spoof) = @_;
   my ($type, $n, $value) = @$opt_desc[1,2,3];

   return 1 if $spoof;

   if ($type eq "const")
   {
      $$value = $n;
   }
   elsif ($type eq "copy")
   {
      $$value = (defined $n) ? ($n) : ($arg);
   }
   elsif ($type eq "arrayconst")
   {
      @$value = @$n;
   }
   elsif ($type eq "hashconst")
   {
      %$value = %$n;
   }
   else
   {
      confess ("internal error: can't handle option type \"$type\"");
   }

   1;
}


sub process_boolean_option
{
   my ($arg, $arglist, $opt_desc, $spoof) = @_;
   my ($value) = $$opt_desc[3];
   
   return 1 if $spoof;

   my ($pos,$neg) = &split_option ($opt_desc);
   confess ("internal error: option $arg not found in argument hash")
      if ($arg ne $pos && $arg ne $neg);

   $$value = ($arg eq $pos) ? 1 : 0;
   1;
}


sub process_call_option
{
   my ($arg, $arglist, $opt_desc, $spoof) = @_;
   my ($option, $args, $value) = @$opt_desc[0,2,3];

   croak "Invalid option table entry for option \"$option\" -- \"value\" " .
         "field must be a code reference"
      unless (ref $value eq 'CODE');

   # This will crash 'n burn big time if there is no spoof code for
   # this option -- but that's why we check %SpoofCode against the
   # arg table from GetOptions!

   $value = $SpoofCode{$arg} if ($spoof);

   my @args = (ref $args eq 'ARRAY') ? (@$args) : ();
   my $result = &$value ($arg, $arglist, @args);
   if (!$result)
   {
      # Wouldn't it be neat if we could get the sub name from the code ref?
      &SetError
         ($ErrorClass || "bad_call",
          $ErrorMessage || "subroutine call from option \"$arg\" failed");
   }

   return $result;

}  # &process_call_option


sub process_eval_option
{
   my ($arg, $arglist, $opt_desc, $spoof) = @_;
   my ($value) = $$opt_desc[3];

   $value = $SpoofCode{$arg} if ($spoof);

   my $up_pkg = &find_calling_package ();
#   print "package $up_pkg; $value";  # DEBUG ONLY
   my $result = eval "package $up_pkg; no strict; $value";

   if ($@)		# any error string set?
   {
      &SetError ("bad_eval",
                 "error evaluating \"$value\" (from $arg option): $@");
      return 0;
   }

   if (!$result)
   {
      &SetError
         ($ErrorClass || "bad_call",
          $ErrorMessage || "code eval'd for option \"$arg\" failed");
   }

   return $result;
}


sub process_pattern_option
{
   my ($arg, $arglist, $opt_desc, $spoof) = @_;
   my ($type, $n, $value) = @$opt_desc[1,2,3];
   my ($dummy, @dummies);

   # This code looks a little more complicated than you might at first
   # think necessary.  But the ugliness is necessary because $value might
   # reference a scalar or an array, depending on whether $n is 1 (scalar)
   # or not (array).  Thus, we can't just assume that either @$value or
   # $$value is valid -- we always have to check which of the two it should
   # be.

   if ($n == 1)                         # scalar-valued option (one argument)
   {
      croak "GetOptions: \"$arg\" option must be associated with a scalar ref"
         unless ref $value eq 'SCALAR';
      $value = \$dummy if $spoof;
      $$value = shift @$arglist;
      return 0 unless &check_value ($$value, $arg, $type, $n);
   }
   else                                 # it's a "vector-valued" option
   {                                    # (fixed number of arguments)
      croak "GetOptions: \"$arg\" option must be associated with an array ref"
         unless ref $value eq 'ARRAY';
      $value = \@dummies if $spoof;
      @$value = splice (@$arglist, 0, $n);
      if (scalar @$value != $n)
      {
         &option_error ($arg, $type, $n);
         return 0;
      }

      my $val;
      foreach $val (@$value)
      {
         return 0 unless &check_value ($val, $arg, $type, $n);
      }
   }  # else

   return 1;

}  # &process_pattern_option


# --------------------------------------------------------------------
# The main public subroutine: GetOptions
# --------------------------------------------------------------------

sub GetOptions
{
   my ($opt_table, $arglist, $new_arglist, $spoof) = @_;
   my (%argpos, $arg, $pos, $opt_ref);
   my ($option_re, @option_list);

   $new_arglist = $arglist if !defined $new_arglist;
   &SetError ("", "");

   # Build a hash mapping option -> position in option table

   &scan_table ($opt_table, \%argpos);

   # Regexp to let us recognize options on the command line

   $option_re = join ("|", @OptionPatterns);

   # Build a list of all acceptable options -- used to match abbreviations

   my $opt_desc;
   foreach $opt_desc (@$opt_table)
   {
      push (@option_list, &split_option ($opt_desc))
	 unless $opt_desc->[1] eq "section";
   }
   push (@option_list, $HelpOption) if $HelpOption;

   # If in spoof mode: make sure we have spoof code for all call/eval options

   if ($spoof)
   {
      my ($opt, $type, $spoof);

      foreach $opt_desc (@$opt_table)
      {
         $opt = $opt_desc->[0];
         $type = $opt_desc->[1];
         $spoof = $SpoofCode{$opt};

         next unless $type eq 'call' || $type eq 'eval';
         croak "No alternate code supplied for option $opt in spoof mode"
            unless defined $spoof;
         croak "Alternate code must be a CODE ref for option $opt"
            if ($type eq 'call' && ref $spoof ne 'CODE');
         croak "Alternate code must be a string for option $opt"
            if ($type eq 'eval' && ref $spoof);
      }
   }

   # Now walk over the argument list

   my @tmp_arglist = @$arglist;
   @$new_arglist = ();
   while (defined ($arg = shift @tmp_arglist))
   {
#     print "arg: $arg\n";

      # If this argument is the option terminator (usually "--") then
      # transfer all remaining arguments to the new arg list and stop
      # processing immediately.

      if (defined $OptionTerminator && $arg eq $OptionTerminator)
      {
         push (@$new_arglist, @tmp_arglist);
         last;
      }

      # If this argument isn't an option at all, just append it to
      # @$new_arglist and go to the next one.

      if ($arg !~ /^($option_re)/o)
      {
         push (@$new_arglist, $arg);
         next;
      }

      # We know we have something that looks like an option; see if it
      # matches or is an abbreviation for one of the strings in
      # @option_list

      $arg = &match_abbreviation ($arg, \@option_list, "%s option: %s");
      if (! $arg)
      {
         warn $Usage if defined $Usage;
         warn "$ErrorMessage\n";
         return 0;
      }

      # If it's the help option, print out the help and return
      # (even if in spoof mode!)

      if ($arg eq $HelpOption)
      {
         &print_help ($opt_table);
         &SetError ("help", "");
         return 0;
      }

      # Now we know it's a valid option, and it's not the help option --
      # so it must be in the caller's option table.  Look up its
      # entry there, and use that for the actual option processing.

      $pos = $argpos{$arg};
      confess ("internal error: didn't find arg in arg hash even " .
               "after resolving abbreviation")
         unless defined $pos;

      my $opt_desc = $opt_table->[$pos];
      my $type = $opt_desc->[1];
      my $handler = $OptionHandlers{$type};

      if (defined $handler && ref ($handler) eq 'CODE')
      {
         if (! &$handler ($arg, \@tmp_arglist, $opt_desc, $spoof))
         {
            warn $Usage if defined $Usage;
            warn "$ErrorMessage\n";
            return 0;
         }
      }
      else
      {
         croak "Unknown option type \"$type\" (found for arg $arg)";
      }
   }     # while ($arg = shift @$arglist)

   return 1;

}     # GetOptions


sub SpoofGetOptions
{
   &GetOptions (@_[0..2], 1);
}

1;
