package Dancer::Plugin::TimeoutManager;

use 5.012002;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Exception ':all';
use Dancer::Plugin;
use Data::Dumper;
use Carp 'croak';

our $VERSION = '0.01';

register 'timeout' => \&timeout;

sub timeout {
    my ($timeout, $method, $path, $code) = @_;

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

    # declare the route in Dancer's registry
    any( [$method], $path, $timeout_route );
}

register_plugin;


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Dancer::Plugin::TimeoutManager - Perl extension for Dancer

=head1 SYNOPSIS

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

Frederic Lechauve, E<lt>frederic@weborama.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Frederic Lechauve

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
