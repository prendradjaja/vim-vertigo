let s:homerow = 'aoeuidhtns'
let s:homerow_onedigit = 'AOEUIDHTNS'
"let s:homerow_onedigit = '	'

let s:keymap = {}
let s:keymap_onedigit = {}

" Add keys from s:homerow to s:keymap
for i in range(0, 8)
  let s:keymap[s:homerow[i]] = i+1
  let s:keymap_onedigit[s:homerow_onedigit[i]] = i+1
endfor
let s:keymap[s:homerow[9]] = 0
let s:keymap_onedigit[s:homerow_onedigit[9]] = 0

command! -nargs=1 TeleportDown call <SID>Teleport('j', 'down', '<args>')
command! -nargs=1 TeleportUp   call <SID>Teleport('k', 'up',   '<args>')

" General description of control flow:
"
" :TeleportDown or :TeleportUp calls Teleport(). Teleport() calls either
" PromptAbsoluteJump() or PromptRelativeJump(), depending on the user's
" 'number' setting.
"
" PromptAbsoluteJump/PromptRelativeJump() prompts the user for input using
" GetUserInput(). If the user doesn't cancel, DoAbsoluteJump/DoRelativeJump()
" is called with the user's input.
"
" If using DoAbsoluteJump(), that function will calculate how many lines up or
" down to go, and then call DoRelativeJump().
"
" DoRelativeJump() does the actual jump.

function! s:Teleport(motion, direction, mode)
"*****************************************************************************
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
"*****************************************************************************

  " If used in visual mode, Vim exited visual mode in order to get here.
  " Re-enter visual mode.
  if a:mode == 'v'
    normal! gv
  endif

  " If using absolute numbering, use an absolute jump. Otherwise, (if using
  " relative numbering, or no line numbering at all) use a relative jump.
  if &number && (!exists('+relativenumber') || !&relativenumber)
    call s:PromptAbsoluteJump(a:mode)
  else
    call s:PromptRelativeJump(a:motion, a:direction, a:mode)
  endif
endfunction

function! s:PromptRelativeJump(motion, direction, mode)
"*****************************************************************************
"* ARGUMENTS: Same as Teleport().
"* EFFECTS:
"    Prompts the user to jump up or down. After this function exits, the
"    cursor is moved. (if the user doesn't cancel)
"    Returns nothing.
"*****************************************************************************
  let promptstr = 'Jump ' . a:direction . ': '
  let m = s:GetUserInput(promptstr)
  if m[0] == 0
    redraw | echo | return
  elseif m[0] == 1
    call s:DoRelativeJump(m[1], a:motion, a:mode)
    return | endif
  let promptstr .= m[1]
  let n = s:GetUserInput(promptstr)
  if n[0] == 0
    redraw | echo | return | endif
  call s:DoRelativeJump(m[1].n[1], a:motion, a:mode)
endfunction

function! s:PromptAbsoluteJump(mode)
"*****************************************************************************
"* ARGUMENTS: See Teleport() for the description of 'mode'.
"* EFFECTS:
"    Prompts the user to jump to a specific line. After this function exits,
"    the cursor is moved. (if the user doesn't cancel)
"    Returns nothing.
"*****************************************************************************
  let promptstr = 'Jump: '
  let m = s:GetUserInput(promptstr)
  if m[0] == 0
    redraw | echo | return
  elseif m[0] == 1
    call s:DoAbsoluteJump(m[1], a:mode)
    return | endif
  let promptstr .= m[1]
  let n = s:GetUserInput(promptstr)
  if n[0] == 0
    redraw | echo | return | endif
  call s:DoAbsoluteJump(m[1].n[1], a:mode)
endfunction

function! s:GetUserInput(promptstr)
"*****************************************************************************
"* ARGUMENTS:
"    promptstr:  A string to prompt the user for input. When first called,
"                 this will be something like 'Jump: ', but after the user
"                 enters a digit, this will be something like 'Jump: 3'. (to
"                 simulate typing)
"* EFFECTS:
"    Prompts the user to jump. Only accepts input from the home row keys or ^C
"    or <Esc> to cancel.
"* RETURNS:
"    A list describing the user's input, as follows.
"    - [0] for canceling
"    - [1, n] for a one-digit number
"    - [2, n] for one digit of a two-digit number
"*****************************************************************************
  redraw
  echohl Question
  echo a:promptstr
  echohl None
  while 1
    let c = nr2char(getchar())
    if c == '' || c == ''
      return [0]
    elseif has_key(s:keymap_onedigit, c)
      return [1, s:keymap_onedigit[c]]
    elseif has_key(s:keymap, c)
      return [2, s:keymap[c]]
    endif
  endwhile
endfunction

function! s:DoRelativeJump(lines, motion, mode)
"*****************************************************************************
"* ARGUMENTS:
"    lines:   How many lines to jump.
"    See Teleport() for the descriptions of 'motion' and 'mode'.
"* EFFECTS:
"    Jumps 'lines' lines up or down, according to 'motion'.
"*****************************************************************************
  let lines_nr = str2nr(a:lines)
  " Set mark for jumplist.
  normal! m'
  " In operator-pending mode, force a linewise motion.
  if a:mode == 'o'
    normal! V
  endif
  execute 'normal! ' . lines_nr . a:motion
  redraw | echo
endfunction

function! s:DoAbsoluteJump(twodigit, mode)
"*****************************************************************************
"* ARGUMENTS:
"    twodigit:  A number from 0-99 -- the last two digits of the line we're
"               jumping to.
"    See Teleport() for the description of 'mode'.
"* EFFECTS:
"    Jumps to the first line on screen with line number ending in 'twodigit',
"    or display an error message if there is no such line.
"*****************************************************************************
  let twodigit_nr = str2nr(a:twodigit)
  let linenr = s:GetAbsJumpLineNumber(twodigit_nr)
  if linenr ==# -1
    redraw
    echohl ErrorMsg
    echo '[Teleport.vim] Bad line number: ' . a:twodigit
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
  call s:DoRelativeJump(lines, motion, a:mode)
endfunction

function! s:GetAbsJumpLineNumber(twodigit)
"*****************************************************************************
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
"*****************************************************************************
  let bottom = line('w0')
  let top = line('w$')
  let hundreds = bottom / 100 * 100
  let try = hundreds + a:twodigit
  if try >= bottom && try <= top
    return try
  endif
  let try = try + 100
  if try <= top
    return try
  endif
  return -1
endfunction
