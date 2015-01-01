package Spotify::Control;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Carp;

use Spotify::Control::HTTP;

=head1 NAME

Spotify::Control - The great new Spotify::Control!

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';


=head1 SYNOPSIS

Spotify::Control::HTTP - Control a local instance of the Spotify app

Currently this only support controlling using the built-in HTTP interface however Applescript and D-BUS support is planned as well.

    use Spotify::Control;

    my $spotify = Spotify::Control->new;
    $spotify->pause; # pause current track
    $spotify->unpause; # resume current track

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my $self = bless {}, shift;
    return unless @_ % 2 == 0;

    my %args = @_;

    my %defaults = (
        _s => undef,

        method => 'http'
    );

    foreach (keys %defaults) {
        $self->{$_} = exists $args{$_} ? $args{$_} : $defaults{$_};
    }

    if ($self->{method} eq 'http') {
        $self->{_s} = Spotify::Control::HTTP->new;
        $self->{_s}->initialise;
    }
    elsif ($self->{method} eq 'applescript') {
        croak __PACKAGE__ . '->new: Applescript not yet supported';
    }
    elsif ($self->{method} eq 'dbus') {
        croak __PACKAGE__ . '->new: D-BUS not yet supported';
    }

    return $self;
}

=head2 ua

Get or set UserAgent object

    say ref($spotify->ua);
    my $ua = my $lwp = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
    $ua->proxy('https', 'http://127.0.0.1:8080');
    $spotify->ua($ua);

=cut

sub ua {
    ( ref $_[1] ) ? shift->{_ua} = $_[1] : shift->{_ua};
}

=head2 spot

Get or set an instance of the child object used to interact with the player. Any object could be used here provided it conforms to the same API

=cut

sub spot {
    ( ref $_[1] ) ? shift->{_s} = $_[1] : shift->{_s};
}

=head2 play

Play a Spotify URI. This can be a track, album or artist

    $spotify->play(uri => 'spotify:track:39XkO83cD29UMRwiAUyT1v');

=cut

sub play {
    croak __PACKAGE__ . '->play: Invalid arguments' unless @_ % 2 == 0;

    return shift->spot->play(@_);
}

=head2 pause

Pause the player

=cut

sub pause {
    return shift->spot->pause;
}

=head2 unpause

Resume the player

=cut

sub unpause {
    return shift->spot->unpause;
}

=head2 status

Fetch the status of the player, return a hashref containing track info and activity state.

=cut

sub status {
    return shift->spot->status;
}

=head1 AUTHOR

Cameron Daniel, C<< <cdaniel at nurve.com.au> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Spotify::Control

=cut

1;
