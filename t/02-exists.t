use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

tied(%hash)->{variants}{en} = "Hello World";
ok (exists $hash{en}, "Varient exists");

tied(%hash)->{variants}{en_GB} = "Hello London";
ok (exists $hash{'en-GB'}, "Varient exists");



done_testing;
