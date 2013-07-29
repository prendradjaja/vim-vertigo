Vertigo.vim
===========

Vertigo.vim is a Vim plugin is based on a simple idea: that moving up and
down using relative line numbers (e.g., `3j`, `15k`) is a very simple and
precise way of moving around vertically, and shouldn't require your hands to
leave home row.

To show how Vertigo works, let's look an example: say you want to go to some
line that you can see (with `relativenumber`) is 14 lines down.

With this plugin, you'd press `<Space>j` to activate "jump mode." Vim then waits
for two home-row keypresses representing a two-digit number, mapping
`asdfghjkl;` to `1234567890`. You then press `af` for 14, and just like
that, you're 14 lines down. Easy! For one-digit numbers, just hit shift.
(`<Space>jF` goes four lines down)

If you use a keyboard layout other than QWERTY, that's not a problem! Dvorak
users: just add `let g:Vertigo_homerow = 'aoeuidhtns'` to your .vimrc file.
Other keyboards should work too. (see `:h vertigo-homerow`)

Why?
----

Can't I just use `4k` or `22j` when I need to? And doesn't [EasyMotion](https://github.com/Lokaltog/vim-easymotion) cover this, and more? Well...

* It's faster.
* It's more comfortable.
* You never have to leave home row.
* It's easy to learn, because your fingers already know where all the numbers
  are.
* Why not?

Installation
------------

__Important note__: Regardless of what installation method you use, Vertigo
requires you to add some mappings to your .vimrc file. (see below)

I use [Pathogen](https://github.com/tpope/vim-pathogen):

    cd ~/.vim
    git clone https://github.com/prendradjaja/vim-vertigo.git bundle/vertigo

Alternatively, with Pathogen, using a git [submodule](http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/):

    cd ~/.vim
    git submodule add https://github.com/prendradjaja/vim-vertigo.git bundle/vertigo

I haven't personally used other plugin managers, but this should work with any of the ordinary plugin managers.

* With [NeoBundle](https://github.com/Shougo/neobundle.vim):
    *  `NeoBundle 'prendradjaja/vim-vertigo'`
* With [Vundle](https://github.com/gmarik/vundle):
    *  `Bundle 'prendradjaja/vim-vertigo'`

For manual installation, copy into `~/.vim`, so plugin/teleport.vim goes to `~/.vim/plugin` and doc/teleport.txt goes to `~/.vim/doc`.

### .vimrc mappings

After installing, you'll have to put in a few mappings into your .vimrc. Here's one option: (though of course you can change `<Space>j` and `<Space>k` to whatever works for you.

    nnoremap <silent> <Space>j :<C-U>VertigoDown n<CR>
    vnoremap <silent> <Space>j :<C-U>VertigoDown v<CR>
    onoremap <silent> <Space>j :<C-U>VertigoDown o<CR>
    nnoremap <silent> <Space>k :<C-U>VertigoUp n<CR>
    vnoremap <silent> <Space>k :<C-U>VertigoUp v<CR>
    onoremap <silent> <Space>k :<C-U>VertigoUp o<CR>

One last thing. Make sure you've got `relativenumber` and/or `number` (while
the examples above used relative numbering, Vertigo works just as well with
absolute line numbers) turned on, and you're good to go!

    set relativenumber

(and/or)

    set number
