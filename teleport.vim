let s:homerow = 'aoeuidhtns'
"let s:homerow = 'asdfghjkl;'

" A dictionary mapping home-row keys to numbers 0-9. -1 is for cancelling.
let s:keymap = {
  \ '': -1,
  \ '': -1}

" Add keys from s:homerow to s:keymap
let num = 1
for s:key in split(s:homerow, '\zs') " split on characters
  let s:keymap[s:key] = num%10
  let num = num + 1
endfor

let s:ABS_JUMP_ERROR_MSG = 'Invalid abs jump: '

function! s:HomeRowNum()
  " Get a number from the user. If a key not in s:keymap is pressed, try again.
  " Returns a number 0-9, or -1 for cancelling.
  while 1
    let c = nr2char(getchar())
    if has_key(s:keymap, c)
      return s:keymap[c]
    endif
  endwhile
endfunction

" The following four functions perform either an absolute jump or a relative
" jump, depending on the value of &number.
function! s:OneDigitJumpDown()
  if &number
    call s:OneDigitAbsJump()
  else
    call s:OneDigitRelJump('j', 'down')
  endif
endfunction

function! s:OneDigitJumpUp()
  if &number
    call s:OneDigitAbsJump()
  else
    call s:OneDigitRelJump('k', 'up')
  endif
endfunction

function! s:TwoDigitJumpDown()
  if &number
    call s:TwoDigitAbsJump()
  else
    call s:TwoDigitRelJump('j', 'down')
  endif
endfunction

function! s:TwoDigitJumpUp()
  if &number
    call s:TwoDigitAbsJump()
  else
    call s:TwoDigitRelJump('k', 'up')
  endif
endfunction

" The following two functions perform a relative jump.
function! s:OneDigitRelJump(motion, direction)
  echo 'Jump ' . a:direction . ': '
  let m = s:HomeRowNum()
  if m == -1
    redraw | echo | return | endif
  execute "normal! " . m . a:motion
  redraw | echo m . a:motion
endfunction

function! s:TwoDigitRelJump(motion, direction)
  echo 'Jump ' . a:direction . ': '
  let m = s:HomeRowNum()
  if m == -1
    redraw | echo | return | endif
  redraw | echo 'Jump ' . a:direction . ': ' . m
  let n = s:HomeRowNum()
  if n == -1
    redraw | echo | return | endif
  execute "normal! " . m . n . a:motion
  redraw | echo m . n . a:motion
endfunction

" The following two functions perform an absolute jump.
function! s:OneDigitAbsJump()
  echo 'Jump (one-digit): '
  let m = s:HomeRowNum()
  if m == -1
    redraw | echo | return | endif
  let twodigit = m
  let linenr = s:GetAbsJumpLineNumber(twodigit)
  if linenr == -1
    redraw | echo s:ABS_JUMP_ERROR_MSG . twodigit | return | endif
  execute linenr
  redraw | echo
endfunction

function! s:TwoDigitAbsJump()
  echo 'Jump: '
  let m = s:HomeRowNum()
  if m == -1
    redraw | echo | return | endif
  redraw | echo 'Jump: ' . m
  let n = s:HomeRowNum()
  if n == -1
    redraw | echo | return | endif
  let twodigit = 10*m + n
  let linenr = s:GetAbsJumpLineNumber(twodigit)
  if linenr == -1
    redraw | echo s:ABS_JUMP_ERROR_MSG . twodigit | return | endif
  execute linenr
  redraw | echo
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

" Dvorak keybindings
"noremap <silent> <Leader><C-H> :call <SID>OneDigitJumpDown()<CR>
"noremap <silent> <Leader><C-T> :call <SID>OneDigitJumpUp()<CR>
"noremap <silent> <Leader>h :call <SID>TwoDigitJumpDown()<CR>
"noremap <silent> <Leader>t :call <SID>TwoDigitJumpUp()<CR>

" QWERTY keybindings
"noremap <silent> <Leader><C-J> :call <SID>OneDigitJumpDown()<CR>
"noremap <silent> <Leader><C-K> :call <SID>OneDigitJumpUp()<CR>
"noremap <silent> <Leader>j :call <SID>TwoDigitJumpDown()<CR>
"noremap <silent> <Leader>k :call <SID>TwoDigitJumpUp()<CR>

command! TeleportOneDigitJumpDown call <SID>OneDigitJumpDown()
command! TeleportOneDigitJumpUp call <SID>OneDigitJumpUp()
command! TeleportTwoDigitJumpDown call <SID>TwoDigitJumpDown()
command! TeleportTwoDigitJumpUp call <SID>TwoDigitJumpUp()
