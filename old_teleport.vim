let s:keymap = {
  \ 'a': 1,
  \ 'o': 2,
  \ 'e': 3,
  \ 'u': 4,
  \ 'i': 5,
  \ 'd': 6,
  \ 'h': 7,
  \ 't': 8,
  \ 'n': 9,
  \ 's': 0,
  \ '.': 5,
  \ 'c': 6,
  \ '': -1,
  \ '': -1,
  \ ' ': -2
  \}
" -1 is for cancelling. -2 is for one-digit numbers

function! s:HomeRowNum()
  while 1
    let c = nr2char(getchar())
    if has_key(s:keymap, c)
      return s:keymap[c]
    endif
  endwhile
endfunction

function! s:RelJump(motion)
  echo '  ' . a:motion

  let m = s:HomeRowNum()
  if m == -1 || m == -2
    redraw | echo | return
  endif
  redraw | echo m . ' ' . a:motion

  let n = s:HomeRowNum()
  if n == -1
    redraw | echo | return
  elseif n == -2
    execute "normal! " . m . a:motion
    redraw | echo ' ' . m . a:motion
  else
    execute "normal! " . m . n . a:motion
    redraw | echo m . n . a:motion
  endif
endfunction

function! s:WindowRange()
  return [line('w0'), line('w$')]
endfunction

function! s:ParseTwoDigit(twodigit, bottom, top)
  " Return the first number in the range (BOTTOM, TOP) that ends in TWODIGIT
  " If no such number exists, return -1
  let hundreds = a:bottom / 100 * 100
  let try = hundreds + a:twodigit
  if try >= a:bottom && try <= a:top
    return try
  endif
  let try = try + 100
  if try <= a:top
    return try
  endif
  return -1
endfunction

noremap <silent> <Leader>j :call <SID>RelJump('j')<CR>
noremap <silent> <Leader>k :call <SID>RelJump('k')<CR>
