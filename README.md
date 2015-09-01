# Tie-Hash-LanguageRange

# NAME

## Tie::Hash::LanguageRange - use RFC Language Ranges for hash keys

# SYNOPSIS

````perl
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
````
    
# DESCRIPTION

This module allows the usage of a Language-Range to lookup a value in a hash.

Language Tags and Language Ranges are a beast, whole RFCs have been written to
define a Language-Tag and how to filter and lookup based on a Language-Range.

The HTTP request header: Accept-Language is a very common usage of the
Language-Range to send a language preference order to the server. Instead of
analyzing the header value and checking what languages are accepted in what
order, just pass in the string as the key for a hash.
