package Tie::Hash::LanguageRange;

require Tie::Hash;
@ISA = 'Tie::Hash';

use Carp;
use DDP;

# use HTTP::Headers::Util;

our @DEFAULTS;          # application wide defaults, global setting
our %PRIORITY_LISTS;    # cache for parsed Language Tag strings

sub import {
    my $class                   = shift;
    if (@_ > 1) {
        carp "More arguments than expected ... assuming list of Language-Tags";
        my $language_range = join ', ', @_;
        @DEFAULTS = _parse_language_range ( $language_range );
    } else {
        my $language_range = shift;
        @DEFAULTS = _parse_language_range ( $language_range );
    };
}

sub TIEHASH {
    my $class                   = shift;
    my @defaults;
    if (@_ > 1) {
        carp "More arguments than expected ... assuming list of Language-Tags";
        my $language_range  = join ', ', @_ ;
        @defaults           = _parse_language_range ( $language_range );
    } elsif (@_ == 1) {
        my $language_range  = shift;
        @defaults           = _parse_language_range ( $language_range );
    } else {
        @defaults           = @DEFAULTS;
    };
    
    my $hash = {
        variants    => {},
        defaults    => \@defaults,
    };
    
    return bless $hash, $class
}

sub STORE {
    my $self                    = shift;
    my $language_tag            = shift;
    my $value                   = shift;
    
    if (not defined $language_tag) {
        carp "Using 'undef' as key is not usual...";
        $language_tag = $self->{defaults}->[0]->{language_tag};
    }
    my $language_key = _normalize_language_tag($language_tag);
    $self->{variants}{$language_key} = $value;
}

sub FETCH {
carp "ARRAY WANTED\n" if wantarray;
    my $self                    = shift;
    my $language_range          = shift;
    my $language_tag            = $self->EXISTS($language_range);
carp "Found Language: $language_tag\n";
    return $self->{variants}{$language_tag} if $language_tag;
    # still haven't found a match
    # but since there was no 'undef' in the list,
    # it seems okay to return anything we have
LANGUAGES_ANYTHING:
    return $self->{variants}{$language_arg}
    
}

=head2 EXISTS

Returns an exisitng Language-Tag for hte one that matches the Language-Range
best. If none found in the exisiting keys, it returns C<FALSE>.

Since C<FALSE> is defined as en empty string, the numeric value 0 or undef and
C<TRUE> as anything else, it is not needed to return 1 for a positive outcome.
Therofore we return the matched C<Language Tag>. This can be useful if one
wants to know what language actually has been used in a lookup with C<FETCH>.

=over

=item Crap!

the values being returned from EXISTS are not transfered to the exists() call,
but are 'normalised' to either the number 1 or the empty string. Surely, this
EXISTS feature would either return C<undef> or a C<Language Tag>. Returning a
possible valid key as "0" would then be interpreted in boolean context as
C<FALSE>

=back

=cut

sub EXISTS {
    my $self                    = shift;
    my $language_range          = shift;
    goto LANGUAGES_DEFAULTS if not defined $language_range;
    # we have a language range (hopefully)
    my @language_weight = _parse_language_range( $language_range );
LANGUAGES_ARGUMENT:
    # let's see if we can find one
    foreach (@language_weight) {
        exit EXISTS if not defined $_->{language_tag}; # don't do alternatives
        # this matching schema needs to be changed a lot
        return $_->{language_tag}
            if exists $self->{variants}->{$_->{language_tag}};
    }
LANGUAGES_DEFAULTS:
    # so, we have not find one in the arguments list, bummer
    # but since there was no 'undef' in the list,
    # it seems okay for a default
    foreach (@{$self->{defaults}}) {
        exit EXISTS if not defined $_->{language_tag}; # don't do alternatives
        return $_->{language_tag}
            if exists $self->{variants}->{$_->{language_tag}};
    }
    
    return;
}

sub FIRSTKEY {
    my $self                    = shift;
    my $a = scalar keys %{$self->{variants}};
    each %{$self->{variants}}
}

sub NEXTKEY {
    my $self                    = shift;
    return each %{ $self->{variants} }
}

sub DELETE {
    my $self                    = shift;
    my $language;
}

sub _languageRange_normalize {
    my $language_range          = shift;
    chomp($language_range);
    return join ', ', map { s/^\s+|\s+$//g; $_ } split ',', $language_range;
}

sub _parse_language_range {
    my $language_range          = shift;
    my @parts  = map { s/^\s+|\s+$//g; $_ } split ',', $language_range;
    my @priorities;
    foreach (@parts) {
        if ( /\s*([a-zA-Z-]+);\s*q\s*=\s*(\d*\.?\d*)/ ) {
            push @priorities, {
                language_tag    => _normalize_language_tag($1),
                quality         => $2,
            };
        } else {
            push @priorities, {
                language_tag    => _normalize_language_tag($_),
                quality         => 1,
            };
        }
    }
    @priorities = sort { $b->{quality} <=> $a->{quality} } @priorities; # reversed
    return @priorities;
}

sub _normalize_language_tag {
    return _language_tag_from_subtags(_parse_language_tag(shift));
}

# returns a hash of normalized subtags
sub _parse_language_tag {
    my $language_tag_check      = shift;
    
    # Simple Regex definitions
    
    my $ALPHA           = qr/[a-z]|[A-Z]/;      # ALPHA
    my $DIGIT           = qr/[0-9]/;            # DIGIT
    
    my $SEP             = qr/[-_]/;
                        # SEPERATOR
                        # -- lenient parsers will use [-_]
                        # -- strict will use [-]
    
    my $alphanum        = qr/$ALPHA|$DIGIT/;   # letters and numbers
    
    goto RFC_4646 if $RFC_4646;
    
    COMPLEX_PARSER:
    
    if ($language_tag_check =~ / ^
            (                                                   # language
                ( $ALPHA{2,3})                                  #     primary language
                (?: $SEP                                        #     extlang
                    ( $ALPHA{3} )
#                   ( $ALPHA{3} ( $SEP $ALPHA{3} ){,2} )
                )?                                              # ... optinal
            )
            (?: $SEP ($ALPHA{4}) )?                             # script
            (?: $SEP ($ALPHA{2} | $DIGIT{3}) )?                 # region
            (?: $SEP ($alphanum{5,8} | $DIGIT $alphanum{3} ) )? # variant
            $ /x
        ) {
        return _normalize_subtags({
            language    => $1,
            primary     => $2,
            extlang     => $3,
            script      => $4,
            region      => $5,
            variant     => $6,
        });
    }
    
    carp "not a language_tag: '$language_tag'\n";
    return;
    
    
    RFC_4646:
    # Regex for recognizing RFC 4646 well-formed tags
    # http://www.rfc-editor.org/rfc/rfc4646.txt
    # http://tools.ietf.org/html/draft-ietf-ltru-4646bis-21
        
    my $grandfathered   = qr/ $ALPHA{1,3}
                              (?: $SEP (?: $alphanum{2,8}) ){1,2}
                            /x;
                        # grandfathered registration
                        # Note: i is the only singleton
                        # that starts a grandfathered tag
    
    my $privateuse      = qr/ (?: x | X )
                              (?: $SEP (?: $alphanum{2,8}) ){1, }
                            /x;
    
    my $singleton       = qr/ [a-w] | [y-z] | [A-W] | [Y-Z] | [0-9] /x;
                        # Single letters: x/X is reserved for private use
    
    my $extension       = qr/ $singleton
                              (?: $SEP (?: $alphanum{2,8}) ){1, }
                            /x;
    
    my $variant         = qr/   $alphanum{5,8}
                            | $DIGIT $alphanum{3}
                            /x;
    
    my $region          = qr/ $ALPHA{2}         # ISO 3166 code
                            | $DIGIT{3}         # UN M.49 code
                            /x;
    
    my $script          = qr/$ALPHA{4}/;        # ISO 15924 code
    
    my $extlang         = qr/(?: $SEP $ALPHA{3}){ ,3}/x;
                                                # reserved for future use
    
    my $language        = qr/ (?: $ALPHA{2,3} $extlang? )
                                                # shortest ISO 639 code
                            | $ALPHA{4}         # reserved for future use
                            | $ALPHA{5,8}       # registered language subtag
                            /x;
    
    my $langtag         = qr/        ($language)
                            (?: $SEP ($script)                          )?
                            (?: $SEP ($region)                          )?
                            (?: $SEP ($variant   (?: $SEP $variant)*)   )?
                            (?: $SEP ($extension (?: $SEP $extension)*) )?
                            (?: $SEP ($privateuse)                      )?
                            /x;
                        # capture each seperate element
    
    my $Language_Tag    = qr/ ^
                              ( $langtag       )
                            | ( $privateuse    )
                            | ( $grandfathered )
                              $
                            /x;
                        # capture the Language Tag
    
# $Language_Tag = qr/($language) $SEP ($region)/x;
    return $Language_Tag;
};

sub _language_tag_from_subtags {
    my $subtags         = shift;
    my $langtag = join '_', #arguably, but hash-keys are more convenient
        map { $subtags->{$_}}
        grep { exists $subtags->{$_} }
            qw /primary extlang script region variant/;
    return $langtag;

}

# sub _normalize_subtags(\%subtags)
#
# - takes a hashref to subtags
#
# - returns a langtag
#
# capitalizes the subtags to usual capitalizing
# 
sub _normalize_subtags {
    my $subtags                 = shift;
    my $newtags                 = {};
    $newtags->{language} = lc $subtags->{language}          if $subtags->{language};
    $newtags->{primary}  = lc $subtags->{primary}           if $subtags->{primary};
    $newtags->{extlang}  = lc $subtags->{extlang}           if $subtags->{extlang};
    $newtags->{script}   = ucfirst lc $subtags->{script}    if $subtags->{script};
    $newtags->{region}   = uc $subtags->{region}            if $subtags->{region};
    $newtags->{variant}  = lc $subtags->{variant}           if $subtags->{variant};
    
    return $newtags;
}

1;
