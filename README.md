# Manhunt

Enhance [fugitive.vim](https://github.com/tpope/vim-fugitive) with easy,
interactive diff browsing.

## Why?

Sometimes it can be useful to rapidly explore the differences between versions
of a file in your Git repository. I refer to this as _scrubbing_ the diff,
just as one would _scrub_ video or audio playback. Unfortunately such
interactivity is awkward in Vim.

Manhunt makes it easy to rapidly diff a file against versions of itself.

## Installation

Get [Pathogen](https://github.com/tpope/vim-pathogen).

Get [fugitive.vim](https://github.com/tpope/vim-fugitive).

And then:

    cd ~/.vim/bundle
    git clone https://github.com/arkwright/vim-manhunt.git

Only tested in Vim 7.4 on OS X using MacVim.

## Usage

Open any file in your Git repo, and execute:

    :Manhunt

Three split windows will be created: two diffed versions of the file at the
top, and a list of all versions of the file at the bottom (the Version List).

    +------------------------------+
    |               |              |
    |    Recent     |   Old        |
    |    Version    |   Version    |
    |    (Diff)     |   (Diff)     |
    |               |              |
    +------------------------------+
    |         Version List         |
    +------------------------------+

From within the Version List window, use the `j` and `k` to browse the diff
view in comfort and style! Use `]c` and `[c` from within the Version List
window to easily step through the file differences in the splits above.

The Version List window contents are based on the output of `:Glog`, but
modified to display additional information, such as the commit date, time, and
author.

Use the `:Manhunt` command to turn Manhunt off when you are finished.

### Modes

Manhunt can operate in three different modes: `working`, `pair`, and `pin`.
You can switch between the two modes at any time, or start Manhunt in a
specific mode, by passing a mode to the `:Manhunt` command, like so:

    :Manhunt working
    :Manhunt pair
    :Manhunt pin

`working` mode is Manhunt's default mode.

#### Working Mode

`working` mode places the working copy of the file in the left diff split, and
the selected version of your file in the right diff split. The Version List
appears in a bottom split, and contains all versions of the file, with the
most recent version at the top.

This mode makes it easy to diff what you are working on against any arbitrary
version of the same file. This mode also makes it possible to pull changes
into the working version of the file using `:diffget`.

#### Pair Mode

`pair` mode places the selected version of the file in the left diff split,
and the previous version of the same file in the right diff split. If there is
no previous version of the file, the same version appears in both splits. The
Version List window appears in a bottom split, and contains all versions of
the file, with the most recent version at the top.

This mode makes it easy to step through the differences between two sequential
versions of the same file. You can also easily scrub through all individual
changes to the file over time, which is great when diffing two distant
versions of the same file produces a lot of noise.

_Protip:_ hammer on `j` and `]c` mappings from within the Version List window
to step backwards through each change made to the file over time.

#### Pin Mode

`pin` mode allows you to select arbitrary versions of the file for display in
the left or right diff split. The Version List window appears in a bottom
split, and contains all versions of the file, with the most recent version at
the top. Within the Version List window, use the `L` and `R` mappings to
select a version intended the left or right diff split, respectively. (Manhunt
will display an error if you attempt to place the older of the two selected
versions in the left split, or vice versa.)

This mode makes it easy to show the changes to a file within a historical
date range, and effortlessly adjust the desired range.

## Mappings

Manhunt provides mappings within the Version List window which make it very
easy to browse the diff splits. By default, you'll be using `j`, `k`, and
`<CR>` to browse versions of the file (`L` and `R` in pin mode); `]c`, and
`[c` to browse differences between the currently diffed versions of the file.

See `:help manhunt-mappings` for more information.

## Configuration

Manhunt allows for customization of default key bindings, invocation command
name, default mode, and diff auto-alignment method.

See `:help manhunt-configuration` for available options.

## Bugs

Probably lots.

Please open a Github issue if you notice something is amiss.

## Contributing

Pull requests, feature requests, ideas, bug reports, etc., are all welcome.

## Changelog

Uses [Semantic Versioning](http://semver.org/).

**0.3.0** (2014-07-05)

* Add a new mode: `pin` mode.
* Use a custom buffer, the Version List, instead of the quickfix window.
* Add signs to Version List to indicate the versions being diffed.
* Change `g:manhunt_key_next_diff` and `g:manhunt_key_previous_diff` default
  bindings to be `]c`, and `[c`, respectively.

**0.2.0** (2014-07-01)

* Add commit date, time, and author to quickfix window.
* Scroll and pretty-format the contents of the quickfix window so that it is
  easier to read.

**0.1.0** (2014-06-29)

* Create `:Manhunt` command with two basic modes: `working` and `pair`.

## Credits

Manhunt is lovingly crafted by [Robert
Arkwright](https://github.com/arkwright).

Manhunt is but a tiny feature added to Tim Pope's amazing
[fugitive.vim](https://github.com/tpope/vim-fugitive).

This plugin would not have been possible without Steve Losh's incredible book:
[Learn Vimscript the Hard
Way](http://learnvimscriptthehardway.stevelosh.com/).

## License

[Unlicense](http://unlicense.org/)
