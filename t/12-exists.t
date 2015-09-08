use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

tied(%hash)->{variants}{en} = "Hello World";
tied(%hash)->{variants}{en_GB} = "Hello London";

ok (exists $hash{en},           "Variant exists");

ok (exists $hash{'en-GB'},      "Variant exists");

ok (exists $hash{'fr, en-GB'},  "Variant exists with Language Range");

ok (exists $hash{'en'},         "Variant exists with partial Language Range");

ok (exists $hash{'en-US'},      "Variant is in Language Range"); # the 'en' variant

done_testing;
