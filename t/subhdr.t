#!perl

# Test that sub-headers work correctly
# Needs a better suite of tests.
use strict;
use Test;
BEGIN { plan tests => 8 };

use Astro::FITS::Header;
use Astro::FITS::Header::Item;

# build a test card
my $int_card = new Astro::FITS::Header::Item(
                               Keyword => 'LIFE',
                               Value   => 42,
                               Comment => 'Life the Universe and everything',
                               Type    => 'INT' );

# build another
my $string_card = new Astro::FITS::Header::Item(
                               Keyword => 'STUFF',
                               Value   => 'Blah Blah Blah',
                               Comment => 'So long and thanks for all the fish',
			       Type    => 'STRING' );

# and another
my $another_card = new Astro::FITS::Header::Item(
                               Keyword => 'VALUE',
                               Value   => 34.5678,
                               Comment => 'A floating point number',
                               Type    => 'FLOAT' );


# Form a header
my $hdr = new Astro::FITS::Header( Cards => [ $int_card, $string_card ]);

# and another header
my $subhdr = new Astro::FITS::Header( Cards => [ $another_card ]);


# now create an item pointing to that subhdr
my $subitem = new Astro::FITS::Header::Item(
					    Keyword => 'EXTEND',
					    Value => $subhdr,
					   );

# Add the item
$hdr->insert(0,$subitem);

#tie
my %header;
tie %header, ref($hdr), $hdr;

# Add another item
$header{EXTEND2} = $subhdr;

# test that we have the correct type
# This should be a hash
ok( ref($header{EXTEND}), "HASH");

# And this should be an Astro::FITS::Header
ok( UNIVERSAL::isa($hdr->value("EXTEND"), "Astro::FITS::Header"));

# Now store a hash
$header{NEWHASH} = { A => 2, B => 3};
ok( $header{NEWHASH}->{A}, 2);
ok( $header{NEWHASH}->{B}, 3);

# Now store a tied hash
my %sub;
tie %sub, ref($subhdr), $subhdr;
$header{NEWTIE} = \%sub;
my $newtie = $header{NEWTIE};
my $tieobj = tied %$newtie;

# We need to disable the stringify operator so that we can compare
# objects directly
eval 'no overload \'""\';';

printf "# The tied object is: %s\n",$tieobj;
printf "# The original object is:: %s\n",$subhdr;

# Compare string representation
# and make sure we have the same object
ok( $tieobj, $subhdr);

# test values
ok($header{NEWTIE}->{VALUE}, $another_card->value);

# Test autovivification
# Note that $hdr{BLAH}->{YYY} = 5 does not work
$header{BLAH}->{XXX};
ok(ref($header{BLAH}), 'HASH');
$header{BLAH}->{XXX} = 5;
ok($header{BLAH}->{XXX}, 5);
