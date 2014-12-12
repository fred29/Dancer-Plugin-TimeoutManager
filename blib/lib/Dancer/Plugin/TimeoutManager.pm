package Dancer::Plugin::TimeoutManager;

use 5.012002;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Exception ':all';
use Dancer::Plugin;
use Data::Dumper;
use Carp 'croak';
use List::MoreUtils qw( none);

our $VERSION = '0.01';

register 'timeout' => \&timeout;

register_exception ('NoTimeout',
        message_pattern => "timeout must be defined and > 0 and is %s",
        );
register_exception ('InvalidMethod',
        message_pattern => "method must be one in get, put, post, delete and %s is used as a method",
        );

my @authorized_methods = ('get', 'post', 'put', 'delete');

sub timeout {
    #my ($timeout, $method, $path, $code) = @_;
    my ($timeout,$method,$pattern, @rest) = @_;
    my $code;
    for my $e (@rest) { $code = $e if (ref($e) eq 'CODE') }
    
    #if no timeout an exception is done
    raise NoTimeout  => $timeout if (!defined $timeout || $timeout <= 0);
    #if method is not valid an exception is done
    if ( none { $_ eq lc($method) } @authorized_methods ){
        raise InvalidMethod => $method;
    }
    
    my $timeout_route = sub {
   
        my $response;
        eval {
            local $SIG{ALRM} = sub { croak ("Route Timeout Detected"); };
            alarm($timeout);
            $response = $code->();
            alarm(0);
        };
        alarm(0);

        # Timeout detected
        if ($@ && $@ =~ /Route Timeout Detected/){
            status(408);
            return "Request Timeout (more than $timeout seconds)";
        }
        # Preserve exceptions caught during route call
        croak $@ if $@;

        # else everything is allright
        return $response;
    };


    my @compiled_rest;
    for my $e (@rest) {
        if (ref($e) eq 'CODE') {
            push @compiled_rest, $timeout_route;
        }
        else {
            push @compiled_rest, $e;
        }
    }

    # declare the route in Dancer's registry
    any [$method] => $pattern, @compiled_rest;
    #any( [$method->method], $method->pattern, $timeout_route );
}

register_plugin;


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Dancer::Plugin::TimeoutManager - Dancer plugin to set a timeout to a Dancer request

=head1 SYNOPSIS
  package MyDancerApp;

  use strict;
  use warnings;

  use Dancer::Plugin::TimeoutManager;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Dancer::Plugin::TimeoutManager, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Frederic Lechauve, E<lt>frederic_lechauve at yahoo.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Frederic Lechauve

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
