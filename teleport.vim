let s:homerow = 'aoeuidhtns'
let s:homerow_shift = 'AOEUIDHTNS'
let s:landing = '_'

let s:keymap = {}
let s:keymap_shift = {}

" Add keys from s:homerow to s:keymap
for i in range(0, 8)
  let s:keymap[s:homerow[i]] = i+1
  let s:keymap_shift[s:homerow_shift[i]] = i+1
endfor
let s:keymap[s:homerow[9]] = 0
let s:keymap_shift[s:homerow_shift[9]] = 0

let s:ABS_JUMP_ERROR_MSG = '[Teleport.vim] Bad line number: '

command! -nargs=1 TeleportDown call <SID>TeleportDown('<args>')
command! -nargs=1 TeleportUp call <SID>TeleportUp('<args>')

function! s:TeleportDown(mode)
  if a:mode == 'v'
    normal! gv
  endif
  if &number
    call s:PromptAbsoluteJump(mode)
  else
    call s:PromptRelativeJump('j', 'down', a:mode)
  endif
endfunction

function! s:TeleportUp(mode)
  if a:mode == 'v'
    normal! gv
  endif
  if &number
    call s:PromptAbsoluteJump(mode)
  else
    call s:PromptRelativeJump('k', 'up', a:mode)
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
  " Returns a list: [0] for canceling, [1, n] for a single digit of a
  " two-digit number, [2, n] for a one-digit number
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
    elseif has_key(s:keymap_shift, c)
      return [2, s:keymap_shift[c]]
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
