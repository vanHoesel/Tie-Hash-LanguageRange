use Tie::Hash::LanguageRange;

use Test::More;

use_ok ('Tie::Hash::LanguageRange');

subtest "Tie::Hash methods implemented" => sub {
    can_ok('Tie::Hash::LanguageRange', 'TIEHASH');
    can_ok('Tie::Hash::LanguageRange', 'STORE');
    can_ok('Tie::Hash::LanguageRange', 'FETCH');
    can_ok('Tie::Hash::LanguageRange', 'EXISTS');
    can_ok('Tie::Hash::LanguageRange', 'FIRSTKEY');
    can_ok('Tie::Hash::LanguageRange', 'NEXTKEY');
    can_ok('Tie::Hash::LanguageRange', 'DELETE');
};

done_testing;
