package Tie::Hash::LanguageRange;

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
        my $language_range = _languageTag_normalize ( shift );
        @DEFAULTS = _languageTag_parse ( $language_range );
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
    my $language_tag    = shift;
    my $value           = shift;
    
    if (not defined $lang) {
        carp "Using 'undef' as key is not usual...";
        $lang = $self->{defaults}->[0];
    }
    $self->{variants}{$language_tag} = $value;
}

sub FETCH {
    my $self            = shift;
    my $language_range  = shift;
    goto LANGUAGES_DEFAULTS if not defined $language_range;
    # we have some language in argument
    my $language_range  = _languageRange_normalize ( $language_range );
    my @language_tags   = _languageRange_parse( $language_range );
LANGUAGES_ARGUMENT:
    # let's see if we can find one
    foreach (@language_tags) {
        exit FETCH if not defined $_->{languages}; # don't do alternatives
        return $self->{variants}->{$_->{languages}}
            if exists $self->{variants}->{$_->{languages}};
    }
LANGUAGES_DEFAULTS:
    # so, we have not find one in the arguments list, bummer
    # but since there was no 'undef' in the list,
    # it seems okay for a default
    foreach (@{$self->{defaults}}) {
        exit FETCH if not defined $_->{languages}; # don't do alternatives
        return $self->{variants}->{$_->{languages}}
            if exists $self->{variants}->{$_->{languages}};
    }
    # still haven't found a match
    # but since there was no 'undef' in the list,
    # it seems okay to return anything we have
LANGUAGES_ANYTHING:
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

sub _languageRange_normalize {
    my $language_range  = shift;
    chomp($language_range);
    return join ', ', map { s/^\s+|\s+$//g; $_ } split ',', $language_range;
}

sub _languageRange_parse {
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
    return @sorted;
}

1;
