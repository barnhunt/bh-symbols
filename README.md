# Inkscape Symbol Libraries for Barn Hunt

[![Inkscape Versions](https://img.shields.io/badge/Inkscape-0.9x%E2%80%931.2-blue.svg?logo=inkscape)](https://inkscape.org/)
[![CC A-NC-SA 4.0 License](https://img.shields.io/badge/license-A--NC--SA%204.0-blue?logo=creativecommons)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

Herein are some [symbol libraries][] that I find useful for drawing
[Barn Hunt][] maps using [Inkscape][].

Currently these include:

- One collection of generally useful bits: start box, boards, rat tube
  markers, etc.
- A number of collections each containing symbols for a distinct size
  of bales.

These symbols generally use a 1:48 scale — one inch on paper
represents four feet of reality.  Additionally, there is currently one
set of bales drawn to a 1:60 (five feet per inch) scale.

## Installation

The easiest way to install these symbol sets is using the new `install`
sub-command of my [`barnhunt`
script](https://github.com/barnhunt/barnhunt):

First install [Inkscape](https://inkscape.org),
[python](https://python.org), and, then,
my [barnhunt script](https://github.com/barnhunt/barnhunt#installation).
Finally, run:

```sh
barnhunt install
```

to install both these symbol sets and my [inkscape
extensions](https://github.com/barnhunt/inkex-bh) into your Inkscape
configuration.

### Manual Installation

It is now recommended to use the `barnhunt install` sub-command to
install these extensions (see above).  However, they may still be
installed manually.

If your using Inkscape 1.0 or later, you should be able to just copy or symlink the `bh_symbols` directory to the `symbols` subdirectory of your Inkscape _user data directory_.

You can discover the location of your user data directory by running `inkscape --user-data-directory` (Inkscape >= 1.0 only).  Generally, the user data directory is `~/.config/inkscape` on Linux, and `%userprofile%\Application Data\Inkscape` on Windows.

### Linux

On Linux, the following should/might work to install the symbol libraries:
```
ln -sf "$PWD/bh_symbols" $(inkscape --user-data-directory)/symbols
```

### Windows

On Windows, you're on your own.  (I use Linux.)

(Contributions of instructions for Windows gladly accepted.)


### Inkscape 0.9x

If you are using Inkscape < 1.0, the symbol `.svg` files must be placed directly in the `symbols` subdirectory of the user data directory.  Inkscape 1.0 and later will find symbol files in a subdirectories of `symbols`, but Inkscape 0.9x will not.

## License

[![Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)][cc a-nc-sa]

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc a-nc-sa].


## Author

Jeff Dairiki, BHAJ-221A <dairiki@dairiki.org>


[Inkscape]: https://inkscape.org/ (The Inkscape home page)
[Barn Hunt]: https://www.barnhunt.com/ (Barn Hunt — a fabulous sport for dogs)
[symbol libraries]: https://wiki.inkscape.org/wiki/SymbolsDialog#Symbol_Libraries
(Terse and outdated information on Inkscape Symbol Libraries)
[cc a-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
(Creative Commons A-NC-SA 4.0 License)
