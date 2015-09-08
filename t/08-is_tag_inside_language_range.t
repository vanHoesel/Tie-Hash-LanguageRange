use Tie::Hash::LanguageRange;

use Test::More;

ok (   Tie::Hash::LanguageRange::_is_tag_inside_language_range('de-CH',      'de-CH'),
    "'de-CH',      'de-CH' Matches the same");

ok (   Tie::Hash::LanguageRange::_is_tag_inside_language_range('de',         'de-CH'),
    "'de',         'de-CH' Matches is shorter tag");

ok ( ! Tie::Hash::LanguageRange::_is_tag_inside_language_range('de-CH-1996', 'de-CH'),
    "'de-CH-1996', 'de-CH' Does not match a more specified");

ok ( ! Tie::Hash::LanguageRange::_is_tag_inside_language_range('nl',         'de-CH'),
    "'nl',         'de-CH' Does not match at all");

done_testing;