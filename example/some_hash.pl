#use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use DDP;

use Tie::Hash::LanguageRange 'en-GB, nl, en, it, en-US';

my %Hello_World;

tie %Hello_World, 'Tie::Hash::LanguageRange', qw/fr nl/;

my $lang = undef;

$Hello_World{$lang} = "Guten Tag";
$Hello_World{nl} = "Hallo Wereld";

my $line = $Hello_World{$lang};
p $line;

my $whoohoo = $Hello_World{'en, nl, de'};
p $whoohoo;

printf("Lang: '%s' => %s\n", $_, $Hello_World{$_}) foreach keys %Hello_World;

# print %Hello_World->DEFAULTS;

__END__