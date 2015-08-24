use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

tied(%hash)->{variants}{en} = "Hello World";
ok (exists $hash{en}, "Variant exists");

tied(%hash)->{variants}{en_GB} = "Hello London";
ok (exists $hash{'en-GB'}, "Variant exists");

ok (exists $hash{'fr, en-GB'}, "Variant exists with Language Range");

done_testing;
