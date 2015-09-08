use Tie::Hash::LanguageRange;

use Test::More;

my %hash;

tie %hash, 'Tie::Hash::LanguageRange';

$hash{en} = "Hello World";
ok (tied(%hash)->{variants}{en}{value} eq "Hello World",
    "Stored a value with simple language");

$hash{NL} = "Hallo Wereld";
ok (tied(%hash)->{variants}{nl}{value} eq "Hallo Wereld",   
    "Stored a value with a capitalized language");

$hash{'En-gB'} = "Hello London";
ok (tied(%hash)->{variants}{'en-GB'}{value} eq "Hello London",
    "Stored a value with a silly capitalized region");

$hash{'ZH-GAN'} = "Hello China";
ok (tied(%hash)->{variants}{'zh-gan'}{value} eq "Hello China",
    "Stored a value with a language extension such as Cantonese");

$hash{'this is not a language tag'} = "Hello Outerspace";

done_testing;
