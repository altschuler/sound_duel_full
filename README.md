Sound-Duel-VM-Football
======================

Sound-Duel-VM-Football is a audio-based pop quiz games, using the [Sound-Duel-Core](https://github.com/bitblueprint/Sound-Duel-Core) front-end.


## Installation

### Notes

 * Make sure you have `npm` installed.

 * The installation assumes you are running on a UNIX-based system (e.g. Linux/Mac OS X), but there is a `Vagrantfile` included for those that aren't. In that case, skip the first two steps installing Meteor and Meteorite.

### Install

 * First, install [Meteor](https://www.meteor.com/):

        # curl https://install.meteor.com | /bin/sh

    Manual installation (for developers) can be found at their [GitHub repo](https://github.com/meteor/meteor).

 * Then install [Meteorite](https://github.com/oortcloud/meteorite) with `npm`:

        # sudo npm install -g meteorite

 * Clone this repo and update submodules:

        # git clone https://github.com/bitblueprint/Sound-Duel-VM-Football.git
        # cd Sound-Duel-VM-Football
        # git submodule init
        # git submodule update

 * Install dependencies with `npm`:

        # npm install

 * Run the app with grunt:

        # grunt


## How it works

The grunt main task (that is run when simply running `grunt` in this directory)
merges the `src` directory and the `lib/core/app` directory into a temporary
directory called `build`. In the `build` directory you can run `meteor` as usual
-- which exactly what the `grunt` command does after having merged the
directories.

_Note: DO NOT run `meteor` in any other directory than `build`. Doing so will
create unwanted files and can break the build step._
