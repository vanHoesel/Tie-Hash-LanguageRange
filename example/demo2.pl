# use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Hash::LanguageTag;

my %greetings;
tie %greetings, 'Hash::LanguageTag', qw/fr nl/;

$greetings{nl} = "Hallo Wereld";
$greetings{hu} = "Helló Világ";
$greetings{ro} = "Salutare, Lume";

print "$greetings{$ARGV[0]}\n";