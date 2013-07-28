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

let s:ABS_JUMP_ERROR_MSG = '[Teleport.vim] Bad line number: '

command! -nargs=1 TeleportDown call <SID>Teleport('j', 'down', '<args>')
command! -nargs=1 TeleportUp   call <SID>Teleport('k', 'up',   '<args>')

" General description of control flow:
"
" Teleport() calls either PromptAbsoluteJump() or PromptRelativeJump(). (from
" here forward, *** will be used in place of 'either absolute or relative',
" e.g., Teleport calls Prompt***Jump(). )
"
" Prompt***Jump() prompts the user for input using GetUserInput(). If the user
" doesn't cancel, Do***Jump() is called with the user's input.
"
" If using DoAbsoluteJump(), that function will calculate how many lines up or
" down to go, and then call DoRelativeJump().
"
" DoRelativeJump() does the actual jump.

function! s:Teleport(motion, direction, mode)
"*****************************************************************************
"* ARGUMENTS:
"   - motion:     Which motion to use. ('j' or 'k')
"   - direction:  A description of the motion. ('down' or 'up')
"                 Used to prompt the user 'Jump down: ' or 'Jump up: '
"   - mode:       An abbreviation for which Vim mode the user is in. ('n',
"                 'v', or 'o', corresponding to :h map-modes)
"* EFFECTS:
"   Prompts the user to jump. After this function exits, the cursor is moved.
"   Returns nothing.
"*****************************************************************************

  " If used in visual mode, Vim exited visual mode in order to get here.
  " Re-enter visual mode.
  if a:mode == 'v'
    normal! gv
  endif

  " If using absolute numbering, use an absolute jump. Otherwise, (if using
  " relative numbering, or no line numbering at all) use a relative jump.
  if &number && !&relativenumber
    call s:PromptAbsoluteJump(a:mode)
  else
    call s:PromptRelativeJump(a:motion, a:direction, a:mode)
  endif
endfunction

function! s:PromptRelativeJump(motion, direction, mode)
  let promptstr = 'Jump ' . a:direction . ': '
  let m = s:GetUserInput(promptstr)
  if m[0] == 0
    redraw | echo | return
  elseif m[0] == 2
    call s:DoRelativeJump(m[1], a:motion, a:mode)
    return | endif
  let promptstr .= m[1]
  let n = s:GetUserInput(promptstr)
  if n[0] == 0
    redraw | echo | return | endif
  call s:DoRelativeJump(m[1].n[1], a:motion, a:mode)
endfunction

function! s:PromptAbsoluteJump(mode)
  let promptstr = 'Jump: '
  let m = s:GetUserInput(promptstr)
  if m[0] == 0
    redraw | echo | return
  elseif m[0] == 2
    call s:DoAbsoluteJump(m[1], a:mode)
    return | endif
  let promptstr .= m[1]
  let n = s:GetUserInput(promptstr)
  if n[0] == 0
    redraw | echo | return | endif
  call s:DoAbsoluteJump(m[1].n[1], a:mode)
endfunction

function! s:GetUserInput(text)
  " Returns a list describing the user's input:
  "  - [0] for canceling
  "  - [1, n] for a single digit of a two-digit number
  "  - [2, n] for a one-digit number
  redraw
  echohl Question
  echo a:text
  echohl None
  while 1
    let c = nr2char(getchar())
    if c == '' || c == ''
      return [0]
    elseif has_key(s:keymap, c)
      return [1, s:keymap[c]]
    elseif has_key(s:keymap_onedigit, c)
      return [2, s:keymap_onedigit[c]]
    endif
  endwhile
endfunction

function! s:DoRelativeJump(amount, motion, mode)
  let amount_nr = str2nr(a:amount)
  normal! m'
  if a:mode == 'o'
    normal! V
  endif
  execute 'normal! ' . amount_nr . a:motion
  redraw | echo
endfunction

function! s:DoAbsoluteJump(twodigit, mode)
  let twodigit_nr = str2nr(a:twodigit)
  let linenr = s:GetAbsJumpLineNumber(twodigit_nr)
  if linenr ==# -1
    redraw
    echohl ErrorMsg
    echo s:ABS_JUMP_ERROR_MSG . a:twodigit
    echohl None
    return | endif
  let curline = line('.')
  if linenr ==# curline
    redraw | echo | return
  elseif linenr < curline
    let amount = curline - linenr
    let motion = 'k'
  else
    let amount = linenr - curline
    let motion = 'j'
  endif
  call s:DoRelativeJump(amount, motion, a:mode)
endfunction

function! s:GetAbsJumpLineNumber(twodigit)
  " Return the first line number in the current window that ends in TWODIGIT, a
  " number from 0 to 99. If no such number exists, return -1.
  " For example, if the window is showing lines 273-319:
    " s:AbsJump(74) = 274
    " s:AbsJump(99) = 299
    " s:AbsJump(12) = 312
    " s:AbsJump(22) = -1
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
