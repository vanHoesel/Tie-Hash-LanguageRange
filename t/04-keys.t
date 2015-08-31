use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

tied(%hash)->{variants}{'en'}       = "Hello World";
tied(%hash)->{variants}{'en-GB'}    = "Hello London";
tied(%hash)->{variants}{'fr'}       = "Bonjour Monde";

my @keys = keys %hash;

ok (scalar @keys == 3, "Got three keys... should be good");

done_testing;
