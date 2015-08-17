# use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Tie::Hash::LanguageRange;

my %greetings;

$greetings{nl} = "Hallo Wereld";
$greetings{hu} = "Helló Világ";
$greetings{ro} = "Salutare, Lume";

print "$greetings{$ARGV[0]}\n";