"""
" User config via:
"
" let g:manhunt_command_name = 'Manhunt'
"""

if exists('g:manhunt_command_name') ==# 0   ||   g:manhunt_command_name ==# ''
  let g:manhunt_command_name = 'Manhunt'
endif

" Dynamically create the Manhunt invocation command, unless an identically
" named command already exists.
if exists(':' . g:manhunt_command_name) ==# 0
  execute 'command! -complete=custom,manhunt#ArgumentAutocomplete -nargs=? ' . g:manhunt_command_name . ' call manhunt#Manhunt(<f-args>)'
endif
