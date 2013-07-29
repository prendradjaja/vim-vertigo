Teleport.vim
============

Teleport.vim is a Vim plugin is based on a simple idea: that moving up and
down using relative line numbers (e.g., `3j`, `15k`) is a very simple and precise
way of moving around vertically, and shouldn't require your hands to leave
home row.

To show how Teleport works, let's look an example: say you want to go to some
line that you can see (with `relativenumber`) is 14 lines down.

With this plugin, you'd press <Space>j to activate "jump mode." Vim then waits
for two home-row keypresses representing a two-digit number, mapping
`asdfghjkl;` to `1234567890`. You then press `af` for `14`, and just like that,
you're 14 lines down.

Installation
------------

    [instructions here]
