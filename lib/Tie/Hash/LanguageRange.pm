package Tie::Hash::LanguageRange;

require Tie::Hash;
@ISA = 'Tie::Hash';

use Carp;
use DDP;

=head1 NAME

Tie::Hash::LanguageRange - use RFC Language Ranges for hash keys

=head1 SYNOPSIS

    use Tie::Hash::LanguageRange;
    
    my %greetings;
    tie %greetings, 'Tie::Hash::LanguageRange';
    
    $greetings{'en'}            = "Hello World";
    $greetings{'en-GB'}         = "Hello London";
    $greetings{'nl'}            = "Hallo Wereld";
    
    print $greetings{'en-US'};  # "Hello World"
    print $greetings{'en-GB'};  # "Hello London"
    
    print $greetings{'en; q=0.8, nl'};
                                # "Hallo Wereld";

    
=head1 DESCRIPTION

This module allows the usage of a Language-Range to lookup a value in a hash.

Language Tags and Language Ranges are a beast, whole RFCs have been written to
define a Language-Tag and how to filter and lookup based on a Language-Range.

The HTTP request header: Accept-Language is a very common usage of the
Language-Range to send a language preference order to the server. Instead of
analyzing the header value and checking what languages are accepted in what
order, just pass in the string as the key for a hash.

 

=head1 METHODS

Since the interface of a tied-hash is no different than a normal hash, there is
nothing worth mentioning about the methods that are implemented. Just use it as
a normal hash.

But... there are some imported things to know:

=head2 STORE

Keys are normalized to common practice for capitalization, so that 'DE-CH' and
'de-ch', both are stored under the same key: 'de-CH' (German as used in
Switzerland). And Ukraine either as 'uk-Latn' or 'uk-Cyrl'.

The hash-keys are also checked on well-formatting, according to RFC ....,
non-conforming keys are rejected.

It will not work trying to use a Language-Tag like 'no-Language' (Although...
that would be 'Norwegian' in the 'Language' variant and still pass the check
- see the RFCs).

=head2 FETCH

=head2 EXISTS

Returns an exisitng Language-Tag for the one that matches the Language-Range
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

So... it returns either true ( '1' ) or false ( "" , the empty string).

See the L<matched_key> method to find out how it has been matched for EXISTS.

=head2 KEYS

Do not be surprised if the C<keys %hash> returns different keys than expected,
you should had done the Language-Tag normalization yourself before hand.

=head2 DELETE

=head2 matched_key

Since one can pass in a Language-Range as a key for lookup operations like
FETCH or EXISTS, it is not sure what langauge actually has been picked for that
operation. After such an operation it is possible to see what language-tag
actually has been selected from the Language-Range in the hash operation. It's
ugly, but works:

    
    my $result = exists $greetings{'en; q=0.8, nl'};
    
    # which either returns '1' or "" (empty space) for true or false
    
    my language_tag = tied(%greetings)->{matched_key};
    

=head2 keys_match

Would it be possible to pass an argument to the `keys` function, it could be
used as a filter, showing only the 
=cut

# use HTTP::Headers::Util;

our @DEFAULT_LIST;              # application wide defaults, global setting
our %PRIORITY_LISTS;            # cache for parsed Language Tag strings

sub import {
    my $class                   = shift;
    
    if (@_ > 1) {
        carp "More arguments than expected ... assuming list of Language-Tags";
        my $language_range = join ', ', @_;
        $DEFAULT_LIST = _priority_list ( $language_range );
    } else {
        my $language_range = shift;
        $DEFAULT_LIST = _priority_list ( $language_range );
    };
}

sub TIEHASH {
    my $class                   = shift;
    my $defaults;
    
    if (@_ > 1) {
        carp "More arguments than expected ... assuming list of Language-Tags";
        my $language_range  = join ', ', @_ ;
        $defaults           = _priority_list ( $language_range );
    } elsif (@_ == 1) {
        my $language_range  = shift;
        $defaults           = _priority_list ( $language_range );
    } else {
        $defaults           = $DEFAULT_LIST;
    }
    
    my $hash = {
        variants    => {},
        defaults    => $defaults,
        matched_key => undef,
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
        carp "... and there is no defaults to fall back" unless $language_tag;

    }
    my $subtags = _parse_language_tag($language_tag);
    my $language_key = _language_tag_from_subtags($subtags);
    carp "Not a language tag: '$language_tag'" unless $language_key;
    $self->{variants}{$language_key} = { value => $value, subtags => $subtags };
}

sub FETCH {
    my $self                    = shift;
    my $language_range          = shift;
    my $language_tag            = $self->EXISTS($language_range);
    
    return $self->{variants}{$language_tag}; # if $language_tag;
}

sub EXISTS {
    my $self                    = shift;
    my $language_range          = shift;
    my $priority_list           = _priority_list( $language_range );
    
    # check for exact matches first
    foreach (@{$priority_list}) {
        return $_->{language_range}
            if exists $self->{variants}{$_->{language_range}}
    }
    
    my $exists = $self->_priority_list_exist ( $priority_list );
    
    $self->{matched_key} = $exists; # store for later if you want to know
    return $exists if $exists;
    
    return; # unless $self->{defaults};
    
    # TODO implement the Defaults when there is no matching key
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
    my $language_range          = shift;
    my $language_tag            = $self->EXISTS($language_range);
    
    return delete $self->{variants}{$language_tag}; # if $language_tag;
}

# sub _priority_list($string)
#
# description:
#   unraffles a string that should look like a priority list as used in HTTP
#   requests. The list it returns is sorted by 'q-values' with the highest
#   priorities first. If no 'q-value' is passed in, it will be set to 1.0.
#   Malformed strings, containing inproper formatted language-ranges, will skipp
#   those bits, allowing for maximum parsebillity
#
# arguments:
#   - string
#
# returns:
#   - arrayref of hashrefs, sorted by 'q-value'
#       - language_range        parsed and normalized Language Range
#       - priority              the 'q-value'
#       - subtags               a hashref of the subtags in the language range
#                               see sub _parse_language_tag
#
sub _priority_list {
    my $language_range          = shift;
    
    my @parts  = map { s/^\s+|\s+$//g; $_ } split ',', $language_range;
    my $elements;
    foreach (@parts) {
        /\s*([-_a-zA-Z]+)\s*(?:;\s*q\s*=\s*(\d*\.?\d*))?/;
        my $subtags             = _parse_language_tag($1);
        next unless $subtags;
        push @{ $elements }, {
            language_range      => _language_tag_from_subtags($subtags),
            priority            => $2 || 1,
            subtags             => $subtags,
        };
    }
    my @priorities = sort { $b->{priority} <=> $a->{priority} } @$elements;
    
    return \@priorities;
}

sub _priority_list_exist {
    my $self                    = shift;
    my $priority_list           = shift;
    
    foreach my $priority_item ( @{ $priority_list } ) {
        foreach my $language_tag (keys %{$self->{variants}} ) {
            if ( _is_tag_inside_language_range( $language_tag, $priority_item->{language_range} ) ) {
                return $language_tag
            }
        }
    }
    
    return;
}

# sub _parse_language_tag($string)
#
# description:
#   takes a Language-Tag string and unraffles it into a hash of subtags
#   acording to RFC 4646.
#   
# arguments:
#   - string
#
# returns:
#   - a hashref with optional:
#       - language
#       - primary
#       - extlang
#       - script
#       - region
#       - variant
#       # un-mentioned subtags in the Language-Tag will not have a key
#
sub _parse_language_tag {
    my $language_tag_check      = shift;
    
    my $language_tag_parser = _language_tag_regex();
    
    if ($language_tag_check =~ / $language_tag_parser /x
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
    
    carp "not a language_tag: '$language_tag_check'\n";
    return;
    
};

# sub _language_tag_regex ();
#
# returns a compiled regular expression to parse a language tag
#
sub _language_tag_regex {
    
    my $ALPHA           = qr/[a-z]|[A-Z]/;      # ALPHA
    my $DIGIT           = qr/[0-9]/;            # DIGIT
    
    my $SEP             = qr/[-_]/;
                        # SEPERATOR
                        # -- lenient parsers will use [-_]
                        # -- strict will use [-]
    
    my $alphanum        = qr/$ALPHA|$DIGIT/;   # letters and numbers
    
    my $regex = qr / ^
        (                                                   # language
            ( $ALPHA{2,3})                                  #     primary language
            (?: $SEP                                        #     extlang
                ( $ALPHA{3} )
#               ( $ALPHA{3} ( $SEP $ALPHA{3} ){,2} )
            )?                                              # ... optinal
        )
        (?: $SEP ($ALPHA{4}) )?                             # script
        (?: $SEP ($ALPHA{2} | $DIGIT{3}) )?                 # region
        (?: $SEP ($alphanum{5,8} | $DIGIT $alphanum{3} ) )? # variant
        $ /x;
    
    return $regex;
}

# sub _normalize_language_tag($string)
#
# description:
#   takes a string and check if it matches the RFC 4646 definition
#   normalizes to common practices (although not required)
#
# arguments:
#   - string
#
# returns:
#   - normalized Langauge-Tag string
#   - undef if not matched
#
sub _normalize_language_tag {
    my $tag = shift;
    my $subtags = _parse_language_tag($tag);
    return _language_tag_from_subtags(_parse_language_tag(shift));
}

# sub _normalize_subtags(\%subtags)
#
# - takes a hashref to subtags
#
# - returns a new hashref with proper capitalization and removed empty subtags
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

# sub _language_tag_from_subtags(\%subtags)
#
# description:
#   combines the subtags into a single string in the order specified by the RFCs
#   
# arguments:
#   - hashref with subtags
#
# returns:
#   - single string
#
sub _language_tag_from_subtags {
    my $subtags         = shift;
    
    my $language_tag = join '-',
        map { $subtags->{$_}}
        grep { exists $subtags->{$_} }
            qw /primary extlang script region variant/;
            
    return $language_tag;
}

# 'de-CH',      'de-ch' "Matches the same"
# 'de',         'de-ch' "Matches is shorter tag"
# 'de-CH-1996', 'de-ch' "Does not match a more specified"
sub _is_tag_inside_language_range {
    my $language_tag            = shift;
    my $language_range          = shift;
    
    $language_tag   .= '-';     # watch out.... we stored it with a underscore
    $language_range .= '-';
    
    my $matching = $language_range =~ /^${language_tag}/;
#   my $matching = $language_tag =~ /^${language_range}/;
    
    return $matching;
}

1;
