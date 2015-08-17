package Hash::LanguageTag;

require Tie::Hash;
@ISA = 'Tie::Hash';

use Carp;
$DEBUG = 0;

# use HTTP::Headers::Util;

our @DEFAULTS;          # application wide defaults, global setting
our %PRIORITY_LISTS;    # cache for parsed Language Tag strings

sub import {
    my $class 	= shift;
    if (@_ > 1) {
        @DEFAULTS = @_;
    } else {
        my $language_tag = _languageTag_normalize ( shift );
        @DEFAULTS = _languageTag_parse ( $language_tag );
    };
}

sub TIEHASH {
    my $class           = shift;
    my @defaults        = @_ ? @_ : @DEFAULTS;
    
    my $hash = {
        variants    => {},
        defaults    => \@defaults,
    };
    
    return bless $hash, $class
}

sub STORE {
    my $self            = shift;
    my $lang            = shift;
    my $value           = shift;
    
    if (not defined $lang) {
        carp "Using 'undef' as key is not usual...";
        $lang = $self->{defaults}->[0];
    }
    $self->{variants}{$lang} = $value;
}

sub FETCH {
    my $self            = shift;
    my $lang            = shift;
    goto LANGUAGES_DEFAULTS if not defined $lang;
    # we have some language in argument
    my $language_tag    = _languageTag_normalize ( $lang );
    my @languages       = _languageTag_parse( $language_tag );
LANGUAGES_ARGUMENT:
carp "LANGUAGES_ARGUMENT:\n";
    # let's see if we can find one
    foreach (@languages) {
use DDP; p $_;
        exit FETCH if not defined $_->{languages}; # don't do alternatives
        return $self->{variants}->{$_->{languages}} if exists $self->{variants}->{$_->{languages}};
    }
LANGUAGES_DEFAULTS:
carp "LANGUAGES_DEFAULTS:\n";
    # so, we have not find one in the arguments list, bummer
    # but since there was no 'undef' in the list,
    # it seems okay for a default
    foreach (@{$self->{defaults}}) {
use DDP; p $_;
        exit FETCH if not defined $_->{languages}; # don't do alternatives
        return $self->{variants}->{$_->{languages}} if exists $self->{variants}->{$_->{languages}};
    }
    # still haven't found a match
    # but since there was no 'undef' in the list,
    # it seems okay to return anything we have
LANGUAGES_ANYTHING:
carp "LANGUAGES_ANYTHING:\n";
    return $self->{variants}{$language_arg}
    
}

sub FIRSTKEY {
    my $self            = shift;
    my $a = scalar keys %{$self->{variants}};
    each %{$self->{variants}}
}

sub NEXTKEY {
    my $self            = shift;
    return each %{ $self->{variants} }
}

sub DELETE {
    my $self            = shift;
    my $language;
}

sub _languageTag_normalize {
    my $language_tag    = shift;
    chomp($language_tag);
    return join ', ', map { s/^\s+|\s+$//g; $_ } split ',', $language_tag;
}
sub _languageTag_parse {
    my $string 	        = shift;
    my @equals          = split ', ', $string;
    my @sorted;
    foreach (@equals) {
        if ( /\s*([a-zA-Z-]+);\s*q\s*=\s*(\d*\.?\d*)/ ) {
            push @sorted, { languages => $1, quality => $2 };
        } else {
            push @sorted, { languages => $_, quality => 1  };
        }
    }
    @sorted = reverse sort { $a->{quality} <=> $b->{quality} } @sorted;
use DDP; p @sorted;
    return @sorted;
}

1;
