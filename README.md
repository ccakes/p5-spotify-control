# Spotify-Control

This is a simple Perl interface for controlling a local instance of Spotify. I've only tested it on OS X but it doesn't use anything too specialised so should work fine on Linux and BSD. Windows is untested.

## Installation

Installation is straight forward using cpanm

```bash
cpanm -i git@github.com:ccakes/p5-spotify-control.git
```

## Usage

```perl
use Spotify::Control;

my $spot = Spotify::Control->new;
say $spot->status->{playing} ? "Currently playing" : "Currently paused";
$spot->play(uri => 'spotify:track:5bj4hb0QYTs44PDiwbI5CS');
```

## Contributing

The main items on the list is an Applescript and D-BUS interface. Following that, a standard format for returning the status across all the implementations, possibly as an object.

- [ ] Discover client HTTP port
- [ ] Spotify::Control::Applescript
- [ ] Spotify::Control::DBUS
- [ ] Standardise ->status response
