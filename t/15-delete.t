use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

tied(%hash)->{variants}{'en'}       = "Hello World";
tied(%hash)->{variants}{'en-GB'}    = "Hello London";
tied(%hash)->{variants}{'fr'}       = "Bonjour Monde";

ok (delete $hash{'en-GB'} eq "Hello London",
    "Delete returns the value for exact match");

ok ( (not exists tied(%hash)->{variants}{'en-GB'}),
    "Delete removed the right key-value pair");

ok (delete @hash{'fr; q=0.8, nl', 'en-GB'} eq "Hello World",
    "Delete returns the value for range match and as last in the list");

ok ( (not exists tied(%hash)->{variants}{'fr'}),
    "Delete removed the right key-value pair");

ok ( (not exists tied(%hash)->{variants}{'en'}),
    "Delete removed the right key-value pair");


done_testing;
