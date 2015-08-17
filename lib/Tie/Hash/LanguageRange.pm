package Tie::Hash::LanguageRange;

require Tie::Hash;
@ISA = 'Tie::Hash';

use Carp;

# use HTTP::Headers::Util;

our @DEFAULTS;          # application wide defaults, global setting
our %PRIORITY_LISTS;    # cache for parsed Language Tag strings

sub import {
    my $class           = shift;
    if (@_ > 1) {
        @DEFAULTS = @_;
    } else {
        my $language_range = _languageRange_normalize ( shift );
        @DEFAULTS = _languageRange_parse ( $language_range );
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
    
    if (not defined $language_tag) {
        carp "Using 'undef' as key is not usual...";
        $language_tag = $self->{defaults}->[0];
    }
    $self->{variants}{$language_tag} = $value;
}

sub FETCH {
carp "ARRAY WANTED\n" if wantarray;
    my $self            = shift;
    my $language_range  = shift;
    goto LANGUAGES_DEFAULTS if not defined $language_range;
    # we have a language range (hopefully)
    my $language_range  = _languageRange_normalize ( $language_range );
    my @language_weight = _languageRange_parse( $language_range );
LANGUAGES_ARGUMENT:
    # let's see if we can find one
    foreach (@language_weight) {
        exit FETCH if not defined $_->{language_tag}; # don't do alternatives
        return $self->{variants}->{$_->{language_tag}}
            if exists $self->{variants}->{$_->{language_tag}};
    }
LANGUAGES_DEFAULTS:
    # so, we have not find one in the arguments list, bummer
    # but since there was no 'undef' in the list,
    # it seems okay for a default
    foreach (@{$self->{defaults}}) {
        exit FETCH if not defined $_->{language_tag}; # don't do alternatives
        return $self->{variants}->{$_->{language_tag}}
            if exists $self->{variants}->{$_->{language-tag}};
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
    my $language_range  = shift;
    my @equals          = split ', ', $language_range;
    my @sorted;
    foreach (@equals) {
        if ( /\s*([a-zA-Z-]+);\s*q\s*=\s*(\d*\.?\d*)/ ) {
            push @sorted, { language_tag => $1, quality => $2 };
        } else {
            push @sorted, { language_tag => $_, quality => 1  };
        }
    }
    @sorted = sort { $b->{quality} <=> $a->{quality} } @sorted;
    return @sorted;
}

1;
