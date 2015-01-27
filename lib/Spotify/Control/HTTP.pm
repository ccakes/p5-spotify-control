package Spotify::Control::HTTP;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Carp;
use URI;
use JSON;
use LWP::UserAgent;

=head1 NAME

Spotify::Control::HTTP - Control your Spotify app using it's built-in HTTP interface

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.11';


=head1 SYNOPSIS

This module provides simple control of a local instance of the Spotify app using it's built-in HTTP interface

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my $self = bless {}, shift;
    return unless @_ % 2 == 0;

    my %args = @_;

    my %defaults = (
        _ua => LWP::UserAgent->new(agent => __PACKAGE__ . '/' . $VERSION),
        _oauth => undef,
        _csrf => undef,

        hostname => join('', map(sprintf("%x", rand 16), 1..8)) . '.spotilocal.com',
        port => undef,

        headers => ['Origin', 'https://open.spotify.com'],
    );

    foreach (keys %defaults) {
        $self->{$_} = exists $args{$_} ? $args{$_} : $defaults{$_};
    }

    # Handle Spotify client on linux only supporting SSLv3
    if ($^O eq 'linux') {
        $self->{_ua}->ssl_opts(SSL_version => 'SSLv3');
    }

    return $self;
}

=head2 initialise

Grab OAuth and CSRF tokens to use in subsequent requests

    $spotify->initialise

=cut

sub initialise {
    my $self = shift;

    my $response;

    # Discover which port the player is listening on
    $self->ua->timeout(1);
    foreach my $p (4370..4380) {
        my $res = $self->ua->get(sprintf('https://%s:%d/service/version.json?service=remote', $self->{hostname}, $p));

        # Valid client should return with a HTTP 200
        if ($res->is_success) {
            $self->{port} = $p;
            last;
        }
    }

    croak __PACKAGE__ . '->initalise: Unable to find running client' unless $self->{port};
    $self->ua->timeout(30);

    # Grab token from Spotify
    # Create a new UserAgent for this because sane sites don't support SSLv3 anymore
    my $ua = LWP::UserAgent->new(agent => __PACKAGE__ . '/' . $VERSION);
    $response = $ua->get('http://open.spotify.com/token');
    croak __PACKAGE__ . '->initialise: ' . $response->decoded_content unless $response->is_success;
    eval { $self->{_oauth} = decode_json($response->content)->{t} };

    eval { $self->{_csrf} = decode_json($self->ua->get(sprintf('https://%s:%d', $self->{hostname}, $self->{port}) . '/simplecsrf/token.json', @{$self->{headers}})->content)->{token} };
    croak __PACKAGE__ . '->initialise: ' . $@ if $@;

    return 1 unless ($self->{_oauth} && $self->{_csrf});
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

=head2 play

Play a Spotify URI. This can be a track, album or artist

    $spotify->play(uri => 'spotify:track:39XkO83cD29UMRwiAUyT1v');

=cut

sub play {
    my $self = shift;
    return unless @_ % 2 == 0;
    my %args = @_;

    croak __PACKAGE__ . '->play: Missing URI' unless exists $args{uri};
    $args{context} = $args{uri} unless exists $args{context}; # add context if not set

    return $self->_request('/remote/play.json', %args);
}

=head2 pause

Pause the player

=cut

sub pause {
    return decode_json(shift->_request('/remote/pause.json', pause => 'true')->content);
}

=head2 unpause

Resume the player

=cut

sub unpause {
    return decode_json(shift->_request('/remote/pause.json', pause => 'false')->content);
}

=head2 status

Fetch the status of the player, return a hashref containing track info and activity state.

=cut

sub status {
    return decode_json(shift->_request('/remote/status.json', returnafter => 1)->content);
}

=head2 _request

Build HTTP request

=cut

sub _request {
    my $self = shift;
    my $uri = shift;
    return unless @_ % 2 == 0;

    my %args = @_;

    my $params = {
        oauth => $self->{_oauth},
        csrf => $self->{_csrf}
    };
    map { $params->{$_} = $args{$_} } keys %args;

    my $url = URI->new(sprintf('https://%s:%d%s', $self->{hostname}, $self->{port}, $uri));
    $url->query_form($params);

    my $response = $self->ua->get($url->as_string, @{$self->{headers}});

    return $response;
}

=head1 AUTHOR

Cameron Daniel, C<< <cdaniel at nurve.com.au> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

perldoc Spotify::Control::HTTP

=cut

1;
