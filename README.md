Vertigo.vim
===========

Moving up and down using relative line numbers (e.g., `3j`, `15k`) is a very
simple and precise way of moving around vertically, and shouldn't require your
hands to leave home row.

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

Can't I just use `14j` or `2k` with vanilla Vim (no plugin needed)? And
doesn't [EasyMotion][a] cover this, and more? Yes! But:

* Vertigo is lightning fast: You never have to leave home row. And unlike
  EasyMotion, you don't have to read the "targets" that appear on-screen
  before completing the motion.
* It's easy to learn, because your fingers already know where all the numbers
  are.

I should admit: As a Dvorak user, I find this very useful, but I think it's
probably less useful for QWERTY users. This is because in QWERTY, something
like `14j` or `2k` with vanilla Vim moves smoothly from the left hand (`1`,
`4`, `2`) to the right (`j`, `k`). But in Dvorak, the `j` and `k` keys are on
the left hand (much like the small digits `12345`, which are much more
commonly used than the large digits `6789`), which makes this key sequence
more cumbersome to type.

I like micro-optimizations. :) If you do too, (and maybe use Dvorak) this
might be the plugin for you.

Installation
------------

__Important note__: Regardless of what installation method you use, Vertigo
requires you to add some mappings to your .vimrc file. (see below)

I use [Pathogen][b]:

    cd ~/.vim
    git clone https://github.com/prendradjaja/vim-vertigo.git bundle/vertigo

Alternatively, with Pathogen, using a git [submodule][c]:

    cd ~/.vim
    git submodule add https://github.com/prendradjaja/vim-vertigo.git bundle/vertigo

I haven't personally used other plugin managers, but this should work with any 
of the ordinary plugin managers.

* With [NeoBundle][d]:
    *  `NeoBundle 'prendradjaja/vim-vertigo'`
* With [Vundle][e]:
    *  `Bundle 'prendradjaja/vim-vertigo'`

For manual installation, copy into `~/.vim`, so plugin/vertigo.vim goes to 
`~/.vim/plugin` and doc/vertigo.txt goes to `~/.vim/doc`.

### .vimrc mappings

After installing, you'll have to put in a few mappings into your .vimrc. 
Here's one option: (though of course you can change `<Space>j` and `<Space>k` 
to whatever works for you.

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
    
Related
-------

- [Emacs port](https://github.com/noctuid/vertigo.el) by noctuid (I have not tried it)



[a]: https://github.com/Lokaltog/vim-easymotion
[b]: https://github.com/tpope/vim-pathogen
[c]: http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/
[d]: https://github.com/Shougo/neobundle.vim
[e]: https://github.com/gmarik/vundle
