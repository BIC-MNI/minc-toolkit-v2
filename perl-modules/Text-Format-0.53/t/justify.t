#!/usr/local/bin/perl

# H.Merijn Brand, 23 Feb 1998 for PROCURA B.V., Heerhugowaard, The Netherlands
# Testing Text::Format for justification only.

# Running this script should yield the data after __END__
# This test does not use tabstops, hanging indents or extra indents

BEGIN	{ $verbose = 1;$| = 1; print "1..8\n"; }
END	{ print "not ok 1\n" unless $loaded; }

use Text::Format 0.46;

$loaded  = 1;

# make test uses .../bin/perl
# perl t/justify.t generates the <DATA> part
$verbose = $^X =~ m:/: ? 0 : 1;

defined $verbose || ($verbose = 1);
print "ok 1\n";
$verbose && print STDERR "# Test 1: Loading Text::Format [Version]\n";

$text = new Text::Format;

$text = "gjyfg uergf au eg uyefg uayg uyger uge uvyger uvga erugf uevg ueyrgv ".
        "uaygerv uygaer uvygaervuy. aureyg aeurgv uayergv uegrv uyagr fuyg uyg".
        " ruvyg aeruvg uevrg auygvre ayergv uyaergv uyagre vuyagervuygervuyg a".
        "reuvg aervg eryvg revg yregv aregv ergv ugre vgerg aerug areuvg auerg".
        " uyrgve uegr vuaguyf gaerfu ageruwf. augawfuygaweufyg rygg auydfg auy".
        "efga uywef. auyefg uayergf uyagr yerg uger uweg g uyg uaygref uerg ae".
        "gr uagr reg yeg ueg";

my $t = Text::Format->new ({
    columns	=> 40,
    firstIndent	=> 0
    });

$test = 2;
print "not ok 2\n" if chk_data (fmt_text (2, $t, 1, 0, 1, $text));
print "not ok 3\n" if chk_data (fmt_text (3, $t, 1, 0, 0, $text));
print "not ok 4\n" if chk_data (fmt_text (4, $t, 0, 1, 1, $text));
print "not ok 5\n" if chk_data (fmt_text (5, $t, 0, 1, 0, $text));

@nat = ("Nederlandse", "Duitse", "Tibetaanse", "Kiribatische", "Kongoleesche",
        "Burger van Nieuw West-Vlaanderland", "Verweggistaneesche");

print "not ok 6\n" if chk_data (fmt_natio (6, $t, 47, 0, 1, @nat));
print "not ok 7\n" if chk_data (fmt_natio (7, $t, 25, 0, 1, @nat));
print "not ok 8\n" if chk_data (fmt_natio (8, $t, 25, 1, 0, @nat));

$verbose && print STDERR "# Test end\n";

### ###########################################################################

sub get_data
{
    # get what should be the result of the next test
    my @data = ();
    unless (defined (@DATA)) {
	while (<DATA>) {
	    chomp;
	    s/^\s*=\s// && s/\s=$//;
	    push (@DATA, $_);
	    }
	}

    while ($DATA[0] =~ m/^#/) {
	shift (@DATA);
	}
    until ($DATA[0] =~ m/^# Test/) {
	push (@data, shift (@DATA));
	}
    @data;
    } # get_data

sub chk_data
{
    my @gen = @_;
    my @dat = get_data ();

    scalar      @gen  == scalar      @dat  || return (1);
    join ("\n", @gen) eq join ("\n", @dat) || return (1);
    print "ok ", $test++, "\n";
    return (0);
    } # chk_data

sub fmt_text
{
    my ($tst, $t, $j, $f, $e, $text) = @_;
    $verbose &&
	print STDERR "# Test $tst: ",
	    $j ? "JUSTIFY"    : "justify",	", ",
	    $f ? "FILL"       : "fill",		", ",
	    $e ? "EXTRASPACE" : "extraspace",	"\n";
    $t->config ({ justify => $j, extraSpace => $e, rightFill => $f });
    my @lines = split ("\n", $t->format ($text));
    $verbose &&
	print STDERR "= ", join (" =\n= ", @lines), " =\n";
    @lines;
    } # fmt_text

sub fmt_natio
{
    my ($tst, $t, $c, $j, $f, @nat) = @_;

    $verbose &&
	print STDERR "# Test $tst: ",
	    $j ? "JUSTIFY" : "justify",	", ",
	    $f ? "FILL"    : "fill",	"\n";
    $t->config ({ columns => $c, justify => $j, rightFill => $f });
    my @lines = split ("\n", $t->format (join (", ", @nat)));
    $verbose &&
	print STDERR "= ", join (" =\n= ", @lines), " =\n";
    @lines;
    } # fmt_natio

__END__
# Test 1: Loading Text::Format [Version]
# Test 2: JUSTIFY, fill, EXTRASPACE
= gjyfg uergf au eg uyefg uayg  uyger  uge =
= uvyger uvga erugf  uevg  ueyrgv  uaygerv =
= uygaer   uvygaervuy.    aureyg    aeurgv =
= uayergv  uegrv  uyagr  fuyg  uyg   ruvyg =
= aeruvg  uevrg  auygvre  ayergv   uyaergv =
= uyagre  vuyagervuygervuyg  areuvg  aervg =
= eryvg revg yregv aregv ergv  ugre  vgerg =
= aerug areuvg auerg uyrgve  uegr  vuaguyf =
= gaerfu ageruwf.   augawfuygaweufyg  rygg =
= auydfg auyefga  uywef.   auyefg  uayergf =
= uyagr yerg uger uweg g uyg uaygref  uerg =
= aegr uagr reg yeg ueg =
# Test 3: JUSTIFY, fill, extraspace
= gjyfg uergf au eg uyefg uayg  uyger  uge =
= uvyger uvga erugf  uevg  ueyrgv  uaygerv =
= uygaer uvygaervuy. aureyg aeurgv uayergv =
= uegrv uyagr fuyg uyg ruvyg aeruvg  uevrg =
= auygvre    ayergv     uyaergv     uyagre =
= vuyagervuygervuyg  areuvg  aervg   eryvg =
= revg yregv aregv ergv ugre  vgerg  aerug =
= areuvg auerg uyrgve uegr vuaguyf  gaerfu =
= ageruwf.  augawfuygaweufyg  rygg  auydfg =
= auyefga uywef. auyefg uayergf uyagr yerg =
= uger uweg g uyg uaygref uerg  aegr  uagr =
= reg yeg ueg =
# Test 4: justify, FILL, EXTRASPACE
= gjyfg uergf au eg uyefg uayg uyger uge   =
= uvyger uvga erugf uevg ueyrgv uaygerv    =
= uygaer uvygaervuy.  aureyg aeurgv        =
= uayergv uegrv uyagr fuyg uyg ruvyg       =
= aeruvg uevrg auygvre ayergv uyaergv      =
= uyagre vuyagervuygervuyg areuvg aervg    =
= eryvg revg yregv aregv ergv ugre vgerg   =
= aerug areuvg auerg uyrgve uegr vuaguyf   =
= gaerfu ageruwf.  augawfuygaweufyg rygg   =
= auydfg auyefga uywef.  auyefg uayergf    =
= uyagr yerg uger uweg g uyg uaygref uerg  =
= aegr uagr reg yeg ueg                    =
# Test 5: justify, FILL, extraspace
= gjyfg uergf au eg uyefg uayg uyger uge   =
= uvyger uvga erugf uevg ueyrgv uaygerv    =
= uygaer uvygaervuy. aureyg aeurgv uayergv =
= uegrv uyagr fuyg uyg ruvyg aeruvg uevrg  =
= auygvre ayergv uyaergv uyagre            =
= vuyagervuygervuyg areuvg aervg eryvg     =
= revg yregv aregv ergv ugre vgerg aerug   =
= areuvg auerg uyrgve uegr vuaguyf gaerfu  =
= ageruwf. augawfuygaweufyg rygg auydfg    =
= auyefga uywef. auyefg uayergf uyagr yerg =
= uger uweg g uyg uaygref uerg aegr uagr   =
= reg yeg ueg                              =
# Test 6:
= Nederlandse, Duitse, Tibetaanse, Kiribatische,  =
= Kongoleesche, Burger van Nieuw                  =
= West-Vlaanderland, Verweggistaneesche           =
# Test 7:
= Nederlandse, Duitse,      =
= Tibetaanse, Kiribatische, =
= Kongoleesche, Burger van  =
= Nieuw West-Vlaanderland,  =
= Verweggistaneesche        =
# Test 8:
= Nederlandse,      Duitse, =
= Tibetaanse, Kiribatische, =
= Kongoleesche, Burger  van =
= Nieuw  West-Vlaanderland, =
= Verweggistaneesche =
# Test End
