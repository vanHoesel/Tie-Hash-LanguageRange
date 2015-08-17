# use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Tie::Hash::LanguageRange;

my %greetings;
tie %greetings, 'Tie::Hash::LanguageRange', qw/fr nl/;

$greetings{nl} = "Hallo Wereld";
$greetings{hu} = "Helló Világ";
$greetings{ro} = "Salutare, Lume";

print "$greetings{$ARGV[0]}\n";