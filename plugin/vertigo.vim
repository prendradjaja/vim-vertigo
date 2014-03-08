" Vertigo.vim
" https://github.com/prendradjaja/vim-vertigo

if exists('g:Vertigo_loaded') || &compatible
  finish
endif
let g:Vertigo_loaded = 1

" Make Ex commands for mapping
command! -nargs=1 VertigoDown call <SID>Vertigo('j', 'down', '<args>')
command! -nargs=1 VertigoUp   call <SID>Vertigo('k', 'up',   '<args>')

" Load user settings
if !exists('g:Vertigo_homerow')
  let s:homerow = 'asdfghjkl;'
else
  let s:homerow = g:Vertigo_homerow
endif

if !exists('g:Vertigo_homerow_onedigit')
  if s:homerow ==# 'asdfghjkl;'
    let s:homerow_onedigit = 'ASDFGHJKL:'
  else
    let s:homerow_onedigit = toupper(s:homerow)
  endif
else
  let s:homerow_onedigit = g:Vertigo_homerow_onedigit
endif

if !exists('g:Vertigo_onedigit_method')
  let s:onedigit_method = 'forcetwo'
else
  let s:onedigit_method = g:Vertigo_onedigit_method
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General description of control flow:
"
" :VertigoDown or :VertigoUp calls Vertigo(). Vertigo() calls either
" PromptAbsoluteJump() or PromptRelativeJump(), depending on the user's
" 'number' setting.
"
" PromptAbsoluteJump/PromptRelativeJump() prompts the user for input using
" GetUserInput(). If the user doesn't cancel, DoAbsoluteJump/DoRelativeJump()
" is called with the user's input.
"
" Either of those functions calls DoJump(), which does the actual jumping.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:Vertigo(motion, direction, mode)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS:
"    motion:     Which motion to use. ('j' or 'k')
"    direction:  A description of the motion. ('down' or 'up')
"                Used to prompt the user 'Jump down: ' or 'Jump up: '
"    mode:       An abbreviation for which Vim mode the user is in. ('n',
"                'v', or 'o', corresponding to :h map-modes)
"* EFFECTS:
"    Prompts the user to jump. After this function exits, the cursor is moved.
"    (if the user doesn't cancel)
"    Returns nothing.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  " If used in visual mode, Vim exited visual mode in order to get here.
  " Re-enter visual mode.
  if a:mode == 'v'
    normal! gv
  endif

  " If using absolute numbering, use an absolute jump. Otherwise, (if using
  " relative numbering, or no line numbering at all) use a relative jump.
  if s:UsingAbsoluteNumbering()
    call s:PromptAbsoluteJump(a:mode)
  else
    call s:PromptRelativeJump(a:motion, a:direction, a:mode)
  endif
endfunction

function! s:PromptRelativeJump(motion, direction, mode)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS: Same as Vertigo().
"* EFFECTS:
"    Prompts the user to jump up or down. After this function exits, the
"    cursor is moved. (if the user doesn't cancel)
"    Returns nothing.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  let promptstr = 'Jump ' . a:direction . ': '
  let m = s:GetUserInput(promptstr)
  if m[0] == 0
    redraw | echo | return
  elseif m[0] == 1
    call s:DoRelativeJump(m[1], a:motion, promptstr.m[1], a:mode)
    return | endif
  let promptstr .= m[1]
  let n = s:GetUserInput(promptstr)
  if n[0] == 0
    redraw | echo | return | endif
  call s:DoRelativeJump(m[1].n[1], a:motion, promptstr.n[1], a:mode)
endfunction

function! s:PromptAbsoluteJump(mode)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS: See Vertigo() for the description of 'mode'.
"* EFFECTS:
"    Prompts the user to jump to a specific line. After this function exits,
"    the cursor is moved. (if the user doesn't cancel)
"    Returns nothing.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  let promptstr = 'Jump: '
  let m = s:GetUserInput(promptstr)
  if m[0] == 0
    redraw | echo | return
  elseif m[0] == 1
    call s:DoAbsoluteJump(m[1], promptstr.m[1], a:mode)
    return | endif
  let promptstr .= m[1]
  let n = s:GetUserInput(promptstr)
  if n[0] == 0
    redraw | echo | return | endif
  call s:DoAbsoluteJump(m[1].n[1], promptstr.n[1], a:mode)
endfunction

function! s:GetUserInput(promptstr)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS:
"    promptstr:  A string to prompt the user for input. When first called,
"                this will be something like 'Jump: ', but after the user
"                enters a digit, this will be something like 'Jump: 3'. (to
"                simulate typing)
"* EFFECTS:
"    Prompts the user to jump. Only accepts input from the home row keys or ^C
"    or <Esc> to cancel.
"* RETURNS:
"    A list describing the user's input, as follows.
"    - [0] for canceling
"    - [1, n] for a one-digit number
"    - [2, n] for one digit of a two-digit number
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  redraw
  echohl Question
  echo a:promptstr
  echohl None
  while 1
    let c = nr2char(getchar())
    if c == '' || c == ''
      return [0]
    elseif has_key(s:keymap_onedigit, c)
      return [s:DigitType(1, s:keymap_onedigit[c]),
            \ s:keymap_onedigit[c]]
    elseif has_key(s:keymap, c)
      return [s:DigitType(0, s:keymap[c]),
            \ s:keymap[c]]
    endif
    call s:BadInput(a:promptstr)
  endwhile
endfunction

function! s:DigitType(usedshift, keypressed)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS:
"    usedshift:   Whether or not the user pressed shift. (boolean)
"    keypressed:  What numerical key the user's keypress corresponded to.
"* RETURNS:
"    A 1 or 2, as described in GetUserInput().
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  if s:onedigit_method ==# 'forcetwo'
    return !a:usedshift + 1
  elseif s:onedigit_method[:4] ==# 'smart'
    if a:keypressed != 0 && a:keypressed <= s:onedigit_method[5]
      return !a:usedshift + 1
    else
      return a:usedshift + 1
    endif
  endif
endfunction

" These dictionaries are used by GetUserInput() to turn home-row keys into
" numbers.
let s:keymap = {}
let s:keymap_onedigit = {}
for i in range(0, 9)
  let s:keymap[s:homerow[i]] = (i+1)%10
  let s:keymap_onedigit[s:homerow_onedigit[i]] = (i+1)%10
endfor

let s:helpmsg = '(<Esc> to cancel)'
function! s:BadInput(promptstr)
  redraw
  echohl Question
  if a:promptstr[len(a:promptstr)-1] == ' '
    echo a:promptstr . s:helpmsg
  else
    echo a:promptstr . ' ' . s:helpmsg
  endif
  echohl None
endfunction

function! s:DoJump(lines, motion, msg, mode)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS:
"    lines:   How many lines to jump.
"    See Vertigo() for the descriptions of 'motion' and 'mode'.
"* EFFECTS:
"    Jumps 'lines' lines up or down, according to 'motion'.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  let lines_nr = str2nr(a:lines)
  if lines_nr ==# 0
    redraw | echo | return | endif
  " Set mark for jumplist.
  normal! m'
  " In operator-pending mode, force a linewise motion.
  if a:mode == 'o'
    normal! V
  endif
  execute 'normal! ' . lines_nr . a:motion
  redraw | echo a:msg
endfunction

function! s:DoRelativeJump(lines, motion, msg, mode)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS:
"    lines:   How many lines to jump.
"    See Vertigo() for the descriptions of 'motion' and 'mode'.
"* EFFECTS:
"    Jumps 'lines' lines up or down, according to 'motion'.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  call s:DoJump(a:lines, a:motion, a:msg.' --', a:mode)
endfunction

function! s:DoAbsoluteJump(twodigit, msg, mode)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS:
"    twodigit:  A number from 0-99 -- the last two digits of the line we're
"               jumping to.
"    See Vertigo() for the description of 'mode'.
"* EFFECTS:
"    Jumps to the first line on screen with line number ending in 'twodigit',
"    or display an error message if there is no such line.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  let twodigit_nr = str2nr(a:twodigit)
  let linenr = s:GetAbsJumpLineNumber(twodigit_nr)
  if linenr ==# -1
    redraw
    echohl ErrorMsg
    echo '[Vertigo.vim] Bad line number: ' . a:twodigit
    echohl None
    return | endif
  let curline = line('.')
  if linenr ==# curline
    redraw | echo | return
  elseif linenr < curline
    let lines = curline - linenr
    let motion = 'k'
  else
    let lines = linenr - curline
    let motion = 'j'
  endif
  call s:DoJump(lines, motion, a:msg.' --> '.linenr, a:mode)
endfunction

function! s:GetAbsJumpLineNumber(twodigit)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"* ARGUMENTS:
"    twodigit:  A number from 0-99 -- the last two digits of the line we're
"               jumping to.
"* RETURNS:
"    The number of the first line on screen with line number ending in
"    'twodigit'. If no such number exists, return -1.
"
"    For example, if the window is showing lines 273-319:
"    s:AbsJump(74) = 274
"    s:AbsJump(99) = 299
"    s:AbsJump(12) = 312
"    s:AbsJump(22) = -1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  let start = line('w0')
  let end = line('w$')
  let hundreds = start / 100 * 100
  let try = hundreds + a:twodigit
  if try >= start && try <= end
    return try
  endif
  let try = try + 100
  if try <= end
    return try
  endif
  return -1
endfunction

function! s:UsingAbsoluteNumbering()
" Returns whether or not the user is currently using absolute numbering.
  return &number && (!exists('+relativenumber') || !&relativenumber)
endfunction
