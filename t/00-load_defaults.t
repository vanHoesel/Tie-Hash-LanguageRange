use Tie::Hash::LanguageRange;

use Test::More;

use Tie::Hash::LanguageRange 'en-US; q=0.7', 'nl', 'en-GB, en; q= 0.9';

my $defaults = $Tie::Hash::LanguageRange::DEFAULT_LIST;

my $expected = [
    {   language_range  => "nl",
        priority        => 1.000,
        subtags         => { language => "nl", primary => "nl" }
    },
    {   language_range  => "en-GB",
        priority        => 1.000,
        subtags         => { language => "en", primary => "en", region => "GB" }
    },
    {   language_range  => "en",
        priority        => 0.900,
        subtags         => { language => "en", primary => "en" }
    },
    {   language_range  => "en-US",
        priority        => 0.700,
        subtags         => { language => "en", primary => "en", region => "US" }
    }
];

is_deeply ( $defaults, $expected, "Created correct Class Defaults");

my %hash;
tie %hash, 'Tie::Hash::LanguageRange';

my $inherited = tied(%hash)->{defaults};

is_deeply ( $inherited, $expected, "Inherited correct Class Defaults");

my %lang;
tie %lang, 'Tie::Hash::LanguageRange', 'zh-Hans', 'zh; q=0.9';

my $expected_china =  [
    {   language_range  => "zh-Hans",
        priority        => 1.000,
        subtags         => { language => "zh", primary => "zh", script => "Hans" }
    },
    {   language_range  => "zh",
        priority        => 0.900,
        subtags         => { language => "zh", primary => "zh" }
    },
];

my $instance = tied(%lang)->{defaults};

is_deeply ( $instance, $expected_china, "Instance defaults");

done_testing;
