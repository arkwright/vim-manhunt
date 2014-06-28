"""
" User config via:
"
" let g:manhunt_default_mode = 'working|pair'
" let g:manhunt_command_name = 'Manhunt'
"""

let s:ManhuntStartBufferNumber = 1

" Allow the user to specify the command name which will invoke Manhunt.
" Fallback to a default value if nothing is specified.
if exists('g:manhunt_command_name') ==# 0   ||   g:manhunt_command_name ==# ''
  let g:manhunt_command_name = 'Manhunt'
endif

" Dynamically create the Manhunt invocation command, unless an identically
" named command already exists.
if exists(":" . g:manhunt_command_name) ==# 0
  execute "command! -complete=custom,s:ManhuntArgumentAutocomplete -nargs=? " . g:manhunt_command_name . " call s:Manhunt(<f-args>)"
endif

"""
" The main Manhunt invocation function.
" If called with a string argument, invokes Manhunt using the specified mode.
" If called without an argument, toggles Manhunt using the default mode.
"
" @param   string    a:1    The mode to use.
"""
function! s:Manhunt(...)
  " Default to 'working' mode if the user has not specified a mode in any way.
  let l:targetMode = 'working'

  " If an argument was not passed, use the default mode.
  if a:0 !=# 1
    if exists('g:manhunt_default_mode') !=# 0   &&   g:manhunt_default_mode !=# ''
      let l:targeMode = g:manhunt_default_mode
    endif
  else
    if a:1 ==# 'working'   ||   a:1 ==# 'pair'   ||   a:1 ==# 'off'
      let l:targetMode = a:1
    endif
  endif

  " Toggle Manhunt.
  if l:targetMode ==# 'off'
    call s:ManhuntOff()
  else
    call s:ManhuntOn(l:targetMode)
  endif
endfunction

"""
" Turns Manhunt off.
"""
function! s:ManhuntOff()
  cclose
  only
  execute "buffer " . s:ManhuntStartBufferNumber
endfunction

"""
" Turns Manhunt on.
"
" @param   string    mode    The mode to use.
"""
function! s:ManhuntOn(mode)
  " winbufnr(0) is the number of the buffer associated with the current window.
  let s:ManhuntStartBufferNumber = winbufnr(0)

  silent! Glog
  vsplit
  cwindow
  execute "silent! normal! \<c-w>Jmzj0viWhhy\<c-w>t\<c-w>l:diffoff\<CR>:edit \<c-r>\"\<CR>:diffthis\<CR>\<c-w>h:diffthis\<CR>gg]czz\<CR>\<c-w>b`z:delmarks z\<CR>"

  nnoremap <buffer> <CR> mz0viWhhy<c-w>t:diffoff<CR>:edit <c-r>"<CR><c-w>b:silent! normal! j<CR>0viWhhy<c-w>t<c-w>l:diffoff<CR>:edit <c-r>"<CR>:diffthis<CR><c-w>h:diffthis<CR>gg:silent! normal! ]czz<CR><c-w>b`z:delmarks z<CR>
  nnoremap <buffer> j jmz0viWhhy<c-w>t:diffoff<CR>:edit <c-r>"<CR><c-w>b:silent! normal! j<CR>0viWhhy<c-w>t<c-w>l:diffoff<CR>:edit <c-r>"<CR>:diffthis<CR><c-w>h:diffthis<CR>gg:silent! normal! ]czz<CR><c-w>b`z:delmarks z<CR>
  nnoremap <buffer> k kmz0viWhhy<c-w>t:diffoff<CR>:edit <c-r>"<CR><c-w>b:silent! normal! j<CR>0viWhhy<c-w>t<c-w>l:diffoff<CR>:edit <c-r>"<CR>:diffthis<CR><c-w>h:diffthis<CR>gg:silent! normal! ]czz<CR><c-w>b`z:delmarks z<CR>
endfunction
