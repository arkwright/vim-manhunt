"""
" User config via:
"
" let g:manhunt_command_name = 'Manhunt'
" let g:manhunt_default_mode = 'working|pair'
" let g:manhunt_diff_align   = 'none|top|center|bottom'
" let g:manhunt_key_next_diff = 'n'
" let g:manhunt_key_previous_diff = 'N'
" let g:manhunt_key_select_next_version = 'j'
" let g:manhunt_key_select_previous_version = 'k'
" let g:manhunt_key_select_version = '<CR>'
"""
if exists('g:manhunt_command_name') ==# 0   ||   g:manhunt_command_name ==# ''
  let g:manhunt_command_name = 'Manhunt'
endif

if exists('g:manhunt_default_mode') ==# 0   ||   g:manhunt_default_mode ==# ''
  let g:manhunt_default_mode = 'working'
endif

if exists('g:manhunt_diff_align') ==# 0   ||   g:manhunt_diff_align ==# ''
  let g:manhunt_diff_align = 'center'
endif

if exists('g:manhunt_key_next_diff') ==# 0   ||   g:manhunt_key_next_diff ==# ''
  let g:manhunt_key_next_diff = 'n'
endif

if exists('g:manhunt_key_previous_diff') ==# 0   ||   g:manhunt_key_previous_diff ==# ''
  let g:manhunt_key_previous_diff = 'N'
endif

if exists('g:manhunt_key_select_next_version') ==# 0   ||   g:manhunt_key_select_next_version ==# ''
  let g:manhunt_key_select_next_version = 'j'
endif

if exists('g:manhunt_key_select_previous_version') ==# 0   ||   g:manhunt_key_select_previous_version ==# ''
  let g:manhunt_key_select_previous_version = 'k'
endif

if exists('g:manhunt_key_select_version') ==# 0   ||   g:manhunt_key_select_version ==# ''
  let g:manhunt_key_select_version = '<CR>'
endif

let s:startBufferNumber = 1
let s:mode              = ''

" Dynamically create the Manhunt invocation command, unless an identically
" named command already exists.
if exists(':' . g:manhunt_command_name) ==# 0
  execute 'command! -complete=custom,s:ArgumentAutocomplete -nargs=? ' . g:manhunt_command_name . ' call s:Manhunt(<f-args>)'
endif

"""
" Returns a newline-separated string of argument autocompletion suggestions.
"
" Vim executes this function when the user presses <tab> while entering
" an argument for the Manhunt invocation command.
"
" @param    string    ArgLead    The leading portion of the argument currently
"                                being completed on.
" @param    string    CmdLine    The entire command line.
" @param    integer   CursorPos  The cursor position within the command line
"                                (byte index)
"
" @return   string               A newline-separated string of autocompletion suggestions.
"""
function! s:ArgumentAutocomplete(ArgLead, CmdLine, CursorPos)
  let l:modes = ['working', 'pair']

  let l:joinedModes = join(l:modes, "\n")

  return l:joinedModes
endfunction

"""
" Aligns the diff split window according to the users's preference.
"""
function! s:DiffAlign()
  if g:manhunt_diff_align ==# 'none'
    return
  elseif g:manhunt_diff_align ==# 'top'
    let l:align = 'zt'
  elseif g:manhunt_diff_align ==# 'center'
    let l:align = 'zz'
  elseif g:manhunt_diff_align ==# 'bottom'
    let l:align = 'zb'
  else
    return
  endif

  execute 'silent! normal! ' . l:align
endfunction

"""
" Toggles diff mode on or off for the Manhunt split windows.
"
" @param   number    a:state    0 to toggle diff off, 1 for on.
"""
function! s:DiffToggle(state)
  if a:state ==# 0
    call s:GotoLeftDiffSplit()
    diffoff
    call s:GotoRightDiffSplit()
    diffoff
  else
    call s:GotoRightDiffSplit()
    diffthis
    call s:GotoLeftDiffSplit()
    diffthis
    
    " Jump to the first difference.
    call s:FirstDiff()
  endif
endfunction

"""
" Goes to the first diff in the split windows.
"""
function! s:FirstDiff()
  call s:GotoLeftDiffSplit()
  silent! normal! gg
  call s:NextDiff()
  call s:GotoQuickfixSplit()
endfunction

"""
" Moves the cursor to the left diff split.
"""
function! s:GotoLeftDiffSplit()
  execute '1wincmd w'
endfunction

"""
" Moves the cursor to the right diff split.
"""
function! s:GotoQuickfixSplit()
  execute '3wincmd w'
endfunction

"""
" Moves the cursor to the right diff split.
"""
function! s:GotoRightDiffSplit()
  execute '2wincmd w'
endfunction

"""
" Returns a value indicating if Manhunt is currently active.
"
" @return    number    Returns 0 if Manhunt is inactive, 1 if it is active.
"""
function! s:IsManhuntActive()
  " tabpagenr() is the number of the current tab page
  " '$' returns the number of windows in the specified tab page
  let l:windowCount = tabpagewinnr(tabpagenr(), '$')

  if l:windowCount ==# 3
    return 1
  endif

  return 0
endfunction

"""
" Returns a value indicating if the specified diff split has been modified.
"
" @param    string    split    The split to check; 'left' or 'right'.
"
" @return   number             Returns 1 if the split is modified, 0 otherwise.
"""
function! s:IsSplitModified(split)
  if a:split ==# 'left'
    call s:GotoLeftDiffSplit()
  else
    call s:GotoRightDiffSplit()
  endif

  return getbufvar(bufname('%'), '&modified')
endfunction

"""
" The main Manhunt invocation function.
" If called with a string argument, invokes Manhunt using the specified mode.
" If called without an argument, toggles Manhunt using the default mode.
"
" @param   string    a:1    The mode to use.
"""
function! s:Manhunt(...)
  if s:IsManhuntActive() ==# 1
    if a:0 ==# 1   &&   (a:1 ==# 'working'   ||   a:1 ==# 'pair')
      " Manhunt us already in this mode.
      if a:0 ==# s:mode
        return
      endif

      if s:IsSplitModified('left')
        " The user cannot change Manhunt modes if the working copy
        " of the file is modified and has not been saved.
        echoerr 'Cannot change Manhunt mode while buffer is modified. Save the buffer first!'
        return
      else
        " Switch modes if Manhunt is active and a valid mode has been provided.
        let s:mode = a:1
        call s:SelectVersion()
        return
      endif
    else
      " Toggle Manhunt off if it is already on.
      call s:Off()
      return
    endif
  endif

  if getbufvar(bufname('%'), '&modified') ==# 1
    echoerr 'Cannot start Manhunt while buffer is modified. Save the buffer first!'
    return
  endif

  if a:0 !=# 1
    " If an argument was not passed, use the default mode.
    if exists('g:manhunt_default_mode') !=# 0   &&   g:manhunt_default_mode !=# ''
      let s:mode = g:manhunt_default_mode
    endif
  else
    let s:mode = a:1
  endif

  " Default to 'working' mode if the user has not specified a valid mode.
  if s:mode !=# 'working'   &&   s:mode !=# 'pair'
    let s:mode = 'working'
  endif

  call s:On()
endfunction

"""
" Goes to the next diff in the split windows.
"""
function! s:NextDiff()
  call s:GotoLeftDiffSplit()
  silent! normal! ]c
  call s:DiffAlign()
  call s:GotoQuickfixSplit()
endfunction

"""
" Turns Manhunt off.
"""
function! s:Off()
  cclose

  " We must go to the left split before closing the right one so that if the
  " user has modified the working file and that file is in the left split, Vim
  " will not throw an error warning the user that they might lose changes.
  call s:GotoLeftDiffSplit()

  only
  execute 'buffer ' . s:startBufferNumber
endfunction

"""
" Turns Manhunt on.
"
" Sets up Manhunt splits and quickfix window.
function! s:On()
  " winbufnr(0) is the number of the buffer associated with the current window.
  let s:startBufferNumber = winbufnr(0)

  silent! Glog
  vsplit
  cwindow
  execute "silent! normal! \<c-w>J"

  execute 'nnoremap <buffer> ' . g:manhunt_key_next_diff . ' :call <SID>NextDiff()<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_previous_diff . ' :call <SID>PreviousDiff()<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_next_version . ' j:call <SID>SelectVersion()<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_previous_version . ' k:call <SID>SelectVersion()<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_version . ' :call <SID>SelectVersion()<CR>'

  call s:SelectVersion()
endfunction

"""
" Goes to the previous diff in the split windows.
"""
function! s:PreviousDiff()
  call s:GotoLeftDiffSplit()
  silent! normal! [c
  call s:DiffAlign()
  call s:GotoQuickfixSplit()
endfunction

"""
" Instructs Manhunt to display a diff appropriate for the version of the file under the cursor.
"""
function! s:SelectVersion()
  call s:GotoQuickfixSplit()

  " line('.') returns the line number for the cursor's current position.
  let l:selectedLine = getline(line('.'))
  let l:nextLine = getline(line('.') + 1)

  " When selecting the bottom version, diff that version it against itself.
  if l:nextLine ==# ''
    let l:nextLine = l:selectedLine
  endif

  let l:pattern = '^[^|]*'

  let l:selectedFile = matchstr(l:selectedLine, l:pattern)
  let l:nextFile = matchstr(l:nextLine, l:pattern)

  call s:DiffToggle(0)

  if s:mode ==# 'working'
    call s:ShowBuffer(s:startBufferNumber, 'left')
    call s:ShowFile(l:selectedFile, 'right')
  elseif s:mode ==# 'pair'
    call s:ShowFile(l:selectedFile, 'left')
    call s:ShowFile(l:nextFile, 'right')
  endif

  call s:DiffToggle(1)

  call s:GotoQuickfixSplit()
endfunction

"""
" Shows the specified buffer in the specified split.
"
" @param    number    a:buffer   The buffer to display in the split.
" @param    string    a:split    The split to display the buffer in. Can be 'left' or 'right'.
"""
function! s:ShowBuffer(buffer, split)
  if a:split ==# 'left'
    call s:GotoLeftDiffSplit()
  else
    call s:GotoRightDiffSplit()
  endif

  execute 'buffer ' . s:startBufferNumber
endfunction

"""
" Shows the specified file in the specified split.
"
" @param    string    a:file     The file to display in the split.
" @param    string    a:split    The split to display the file in. Can be 'left' or 'right'.
"""
function! s:ShowFile(file, split)
  if a:split ==# 'left'
    call s:GotoLeftDiffSplit()
  else
    call s:GotoRightDiffSplit()
  endif

  execute 'edit ' . a:file
endfunction
