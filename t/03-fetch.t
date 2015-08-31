use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

tied(%hash)->{variants}{'en'}       = "Hello World";
tied(%hash)->{variants}{'en-GB'}    = "Hello London";
tied(%hash)->{variants}{'fr'}       = "Bonjour Monde";

ok ($hash{'en'}                 eq "Hello World",
    "Retrieve simple variant");

ok ($hash{'en-GB'}              eq "Hello London",
    "Retrieve variant with region subtag");

ok ($hash{'de, en-GB'}          eq "Hello London",
    "Retrieve variant with single match");

ok ($hash{'fr'}                 eq "Bonjour Monde",
    "Retrieve another variant");

ok ($hash{'fr, en-GB'}          eq "Bonjour Monde",
    "Retrieve variant with first match");

ok ($hash{'fr ;q=0.8, en-GB'}   eq "Hello London",
    "Retrieve variant with priority match");

ok ($hash{'en-US'}              eq "Hello World",
    "Retrieve variant shorter match");

my ($val1, $val2) = @hash{'fr', 'en'};
ok ( ($val1 eq "Bonjour Monde" and $val2 eq "Hello World"),
    "Retrieve two values at the same time");

done_testing;
