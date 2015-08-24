use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

tied(%hash)->{variants}{en} = "Hello World";
ok ($hash{en} eq "Hello World", "Retrieve simple variant");

tied(%hash)->{variants}{en_GB} = "Hello London";
ok ($hash{'en-GB'} eq "Hello London", "Retrieve variant with region subtag");

ok ($hash{'fr, en-GB'} eq "Hello London", "Retrieve variant with single match");

tied(%hash)->{variants}{fr} = "Bonjour Monde";
ok ($hash{fr} eq "Bonjour Monde", "Retrieve another variant");

ok ($hash{'fr, en-GB'} eq "Bonjour Monde", "Retrieve variant with first match");

ok ($hash{'fr ;q=0.8, en-GB'} eq "Hello London", "Retrieve variant with priority match");

done_testing;
