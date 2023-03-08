## Changes

### 1.0.0rc5 (unreleased)

- Append scale (e.g. `-60to1`) to the id attributes of symbols with
  scale other than 48:1. This *should* make symbol names universally unique
  across all symbol in *bh-symbols*.

- Add `bh:package-name` and `bh:package-version` attributes to all symbols.
  This allows for determining which version of each symbol one has in ones drawing.

- Add tests for dangling `xlink:href` and `url()` references, and check
  the the `id` attributes of our symbols are globally unique.

#### Bugs Fixed

- Fix missing strings in the flat alt anchor bales (the ones with the
  red dashed outlines.)

### 1.0.0rc4 (2023-03-05)

#### Bugs

- Inkscape’s “cleanup document” command was deleting the component symbols that
  are copied into each symbol.  Here we switch to hiding the patterns and referenced
  symbols in an <svg:g style="display:none;"> rather than in a nested <svg:defs>
  element. That seems to prevent the carnage.

### 1.0.0rc3 (2022-02-20)

- More alt (dashed) bale legend variations (for Sandra).

### 1.0.0rc2 (2022-02-19)

- Add a bunch of new bale legend variations.

- Rename the bale symbol sets from, e.g., *“Two-String Bales,
  39x18x15”* to *“Bales, Two-String, 39x18x15”*.  This makes Inkscape
  list them closer to the top of its list of symbol sets, thus
  minimizing the need to scroll.

#### Bugs

- Copy patterns and referenced symbols into each bale symbol. This
  fixes the issue where the bale stipple patterns were not making it
  into the referencing documents.

- Fix vertical alignment of text in bale legends.

- Remove `id` attributes from the symbol document `<title>` element.
  The `id` attribute was causing recent Inkscapes to fail to recognize the title.
  
### 1.0.0rc1 (2022-10-17)

First tagged release.

We are now publishing a zip archive, ready for unzipping
directly to your Inkscape symbols directory on each of
our GitHub [Release pages](https://github.com/barnhunt/bh-symbols/releases).
