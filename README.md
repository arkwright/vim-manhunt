# Manhunt

Enhance [fugitive.vim](https://github.com/tpope/vim-fugitive) with easy
diff browsing.

## Why?

Sometimes you're forced to manually search all commits to a certain file,
painstakingly diffing each commit against another until you find what you
are looking for.

This plugin makes it easy to diff the incremental changes to a file over
time.

## Installation

Get [Pathogen](https://github.com/tpope/vim-pathogen).

Get [fugitive.vim](https://github.com/tpope/vim-fugitive).

And then:

    cd ~/.vim/bundle
    git clone https://github.com/arkwright/vim-manhunt.git

Only tested in Vim 7.4 on OS X using MacVim.

**This plugin is very fragile. It is a work in progress. Proceed at
your own risk!**

## Usage

Open any file in your Git repo, and execute:

    :Manhunt

Use `j` and `k` to browse the quickfix window. The diff view will update
automatically. The file under the cursor is loaded into the left split.
The file one line below the cursor is loaded into the right split.

## Configuration

None yet.

# License

[Unlicense](http://unlicense.org/)
