# contacts #

`contacts` is a command line interface to the Mac OS X Address Book.

## Overview ##

`contacts` is a quick an easy way to search the OS X Address Book from the command line.  An eventual goal is to fully replace the now unmaintained program of the [same name][theotherguy].  Functionality is currently limited to providing input for a [mutt address query][muttquerydoc] and for outputting alias and group entries for mutt.  

[theotherguy]: http://gnufoo.org/contacts/
[muttquerydoc]: http://dev.mutt.org/trac/wiki/QueryCommand

## Example Usage ##

    contacts -m somename

This returns all matches for *somename* in your address book in a simple format:

    name    email

`contacts` can also output alias and group entries for inclusion in your mutt rc file.See the man file for more detail.

    contacts -a --all

## Installing ##

Easy!

    make
    make install

Alternately, I'm working on getting this into homebrew, but for now you can install it from my github formula repository (beware of the other formula...).

    brew install https://raw.github.com/tgray/homebrew-tgbrew/master/contacts2.rb

## Configuring ##

As of this time, there is no configuration.

## Other ##

As stated previously, eventually `contacts` will be a full fledged replacement for the *other* [`contacts`][theotherguy].  For now, it isn't.  What it does do is intelligently search your Address Book and format the output so you can use it for the input of a mutt query call.

It is designed to be used with [`muttqt`][muttqt], a mutt query tool, which wraps `contacts` as well as manages other address query sources.

[muttqt]: https://github.com/tgray/muttqt

## Developer Info ##

`contacts` is written by [Tim Gray][tggit].  It's obviously inspired by the other [`contacts`][theotherguy].

The `contacts` homepage can be located on github at <https://github.com/tgray/contacts>.

[tggit]: https://github.com/tgray

### Other contributors ###

- Sebastian Tramp - gave me the idea to also search companies.

## License ##

`contacts` is released under an Apache License 2.0.  Please see the `LICENSE.markdown` file included with the distribution.
