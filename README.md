# Manhunt

Enhance [fugitive.vim](https://github.com/tpope/vim-fugitive) with easy,
interactive diff browsing.

## Why?

Sometimes it can be useful to rapidly explore the differences between versions
of a file in your Git repository. I refer to this as "scrubbing" the diff,
just as one would "scrub" video or audio playback. Unfortunately such
interactivity is awkward in vim.

Manhunt makes it easy to rapidly diff a file against versions of itself, or
the differences between two sequential versions of a file.

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

Two diff splits appear, along with the quickfix window.

Use `j` and `k` to browse the quickfix window. The diff view will update
automatically. Use `n` and `N` from within the quickfix window to easily
step through the file differences in the splits above.

Use the `:Manhunt` command to turn Manhunt off when you are finished.

### Modes

Manhunt can operate in two different modes: 'working' and 'pair'. You can
switch between the two modes at any time by passing a mode to the `:Manhunt`
command, like so:

    :Manhunt working
    :Manhunt pair

'working' mode is Manhunt's default mode. You can change the default mode by
setting the `g:manhunt_default_mode` option.

#### Working Mode

'working' mode places the working copy of the file in the left diff split, and
the selected version of your file in the right diff split. The quickfix window
appears in a bottom split, and contains all versions of the file, with the
most recent version at the top.

This mode makes it easy to diff what you are working on against any arbitrary
version of the same file. This mode also makes it possible to pull changes
into the working version of the file.

#### Pair Mode

'pair' mode places the selected version of the file in the left diff split,
and the previous version of the same file in the right diff split. If there is
no previous version of the file, the same version appears in both splits. The
quickfix window appears in a bottom split, and contains all versions of the
file, with the most recent version at the top.

This mode makes it easy to step through the differences between two sequential
versions of the same file. You can also easily scrub through all individual
changes to the file over time, which is great when diffing two distant
versions of the same file produces a lot of noise.

Protip: hammer on `j` and `n` keys from within the quickfix window to step
backwards through each change made to the file over time. Your workflow will
resemble this: `jnnnnnnjnnnjnnnnnjnn`.

## Mappings

Manhunt provides mappings within the quickfix window which make it very easy
to browse the diff splits. By default, you'll be using `j`, `k`, and `<CR>` to
browse versions of the file; `n`, and `N` to browse differences between the
currently diffed versions of the file.

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

**0.1.0**

* Create `:Manhunt` command with two basic modes: `working` and `pair`.

## Credits

Manhunt is but a tiny feature added to Tim Pope's amazing
[fugitive.vim](https://github.com/tpope/vim-fugitive).

This plugin would not have been possible without Steve Losh's incredible book:
[Learn Vimscript the Hard
Way](http://learnvimscriptthehardway.stevelosh.com/).

## License

[Unlicense](http://unlicense.org/)
