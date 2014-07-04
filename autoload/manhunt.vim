"""
" User config via:
"
" let g:manhunt_default_mode = 'working|pair|pin'
" let g:manhunt_diff_align   = 'none|top|center|bottom'
" let g:manhunt_key_next_diff = 'n'
" let g:manhunt_key_previous_diff = 'N'
" let g:manhunt_key_select_left_version = 'L'
" let g:manhunt_key_select_next_version = 'j'
" let g:manhunt_key_select_previous_version = 'k'
" let g:manhunt_key_select_right_version = 'R'
" let g:manhunt_key_select_version = '<CR>'
"""

if exists('g:manhunt_default_mode') ==# 0   ||   g:manhunt_default_mode ==# ''
  let g:manhunt_default_mode = 'working'
endif

if exists('g:manhunt_diff_align') ==# 0   ||   g:manhunt_diff_align ==# ''
  let g:manhunt_diff_align = 'center'
endif

if exists('g:manhunt_key_next_diff') ==# 0   ||   g:manhunt_key_next_diff ==# ''
  let g:manhunt_key_next_diff = ']c'
endif

if exists('g:manhunt_key_previous_diff') ==# 0   ||   g:manhunt_key_previous_diff ==# ''
  let g:manhunt_key_previous_diff = '[c'
endif

if exists('g:manhunt_key_select_left_version') ==# 0   ||   g:manhunt_key_select_left_version ==# ''
  let g:manhunt_key_select_left_version = 'L'
endif

if exists('g:manhunt_key_select_next_version') ==# 0   ||   g:manhunt_key_select_next_version ==# ''
  let g:manhunt_key_select_next_version = 'j'
endif

if exists('g:manhunt_key_select_previous_version') ==# 0   ||   g:manhunt_key_select_previous_version ==# ''
  let g:manhunt_key_select_previous_version = 'k'
endif

if exists('g:manhunt_key_select_right_version') ==# 0   ||   g:manhunt_key_select_right_version ==# ''
  let g:manhunt_key_select_right_version = 'R'
endif

if exists('g:manhunt_key_select_version') ==# 0   ||   g:manhunt_key_select_version ==# ''
  let g:manhunt_key_select_version = '<CR>'
endif

let s:leftSignLineNum           = 0
let s:manhuntBufferFileName     = '[Manhunt]'
let s:manhuntBufferNumber       = 0
let s:manhuntLSignName          = 'ManhuntL'
let s:manhuntLRSignName         = 'ManhuntLR'
let s:manhuntRSignName          = 'ManhuntR'
let s:mode                      = ''
let s:rightSignLineNum          = 0
let s:selectedNewVersionLineNum = 1
let s:selectedOldVersionLineNum = 1
let s:startFilePath             = ''
let s:summaryFormatSeparator    = ';-----;'

execute 'sign define ' . s:manhuntLSignName . ' text=L texthl=Search'
execute 'sign define ' . s:manhuntRSignName . ' text=R texthl=Search'
execute 'sign define ' . s:manhuntLRSignName . ' text=LR texthl=Search'

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
function! manhunt#ArgumentAutocomplete(ArgLead, CmdLine, CursorPos)
  let l:modes = ['working', 'pair', 'pin']

  let l:joinedModes = join(l:modes, "\n")

  return l:joinedModes
endfunction

"""
" Aligns the diff split window according to the users's preference.
"""
function! s:CreateManhuntBuffer()
  execute 'noswapfile botright 10new ' . s:manhuntBufferFileName
  let s:manhuntBufferNumber = bufnr('%')
  setlocal buftype=nofile
  setlocal bufhidden=delete

  setlocal modifiable
  execute '%d'
  call append(0, s:TransformQuickfixData())
  execute 'normal! ddgg0'
  setlocal nomodifiable
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
  call s:GotoManhuntSplit()
endfunction

"""
" Call fugitive's :Glog command, but modify the results
" returned to the quickfix window.
"""
function! s:Glog()
  let l:originalSummaryFormat = g:fugitive_summary_format

  " This format string is appended by fugitive when it calls `git log --pretty=format:<string>`
  " %ci is the committer date in ISO-8601 format
  " %cn is the committer name
  " %s is the commit subject line
  let g:fugitive_summary_format = '%ci' . s:summaryFormatSeparator . '%cn' . s:summaryFormatSeparator . '%s'

  echo 'Manhunt is calling :Glog. This might take a while...'
  silent! Glog
  let g:fugitive_summary_format = l:originalSummaryFormat
endfunction

"""
" Moves the cursor to the left diff split.
"""
function! s:GotoLeftDiffSplit()
  execute '1wincmd w'
endfunction

"""
" Moves the cursor to the Manhunt split.
"""
function! s:GotoManhuntSplit()
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

  if l:windowCount >=# 3
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
function! manhunt#Manhunt(...)
  if s:IsManhuntActive() ==# 1
    if a:0 ==# 1   &&   (a:1 ==# 'working'   ||   a:1 ==# 'pair'   ||   a:1 ==# 'pin')
      if a:1 ==# s:mode
        " Manhunt is already in this mode.
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
        call s:SelectVersion('switch')
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
  if s:mode !=# 'working'   &&   s:mode !=# 'pair'   &&   s:mode !=# 'pin'
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
  call s:GotoManhuntSplit()
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
  execute 'buffer ' . s:startFilePath
endfunction

"""
" Turns Manhunt on.
"
" Sets up Manhunt splits and quickfix window.
"""
function! s:On()
  let s:startFilePath = expand('%:p')

  call s:Glog()
  vsplit
  call s:CreateManhuntBuffer()

  execute 'nnoremap <buffer> ' . g:manhunt_key_next_diff . ' :call <SID>NextDiff()<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_previous_diff . ' :call <SID>PreviousDiff()<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_next_version . ' j:call <SID>SelectVersion("next")<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_previous_version . ' k:call <SID>SelectVersion("previous")<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_version . ' :call <SID>SelectVersion("this")<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_left_version . ' :call <SID>SelectVersion("left")<CR>'
  execute 'nnoremap <buffer> ' . g:manhunt_key_select_right_version . ' :call <SID>SelectVersion("right")<CR>'

  " Working mode places the cursor on the second line by default,
  " because this will produce a useful diff between working copy
  " and latest committed version. The cursor is not moved when
  " switching from another mode *to* working mode, because when
  " making such a switch it can be useful to continue to include
  " the selected version in the new diff.
  if s:mode ==# 'working'
    execute 'normal! ggj'
  endif

  call s:SelectVersion('init')
endfunction

"""
" Returns the supplied string padded with spaces to the specified length,
" adding whitespace to the left or right side as preferred.
"
" @param    string    str     The string to be padded.
" @param    string    len     The length to pad the string to.
" @param    string    side    The side to add the whitespace to: 'left' or 'right'.
"
" @return   string            The input string, padded.
"""
function! s:Pad(str, len, side)
  if a:side ==# 'left'
    return repeat(' ', a:len - len(a:str)) . a:str
  elseif a:side ==# 'right'
    return a:str . repeat(' ', a:len - len(a:str))
  endif

  return a:str
endfunction

"""
" Goes to the previous diff in the split windows.
"""
function! s:PreviousDiff()
  call s:GotoLeftDiffSplit()
  silent! normal! [c
  call s:DiffAlign()
  call s:GotoManhuntSplit()
endfunction

"""
" Transforms and returns data in the quickfix window,
" such that the result is suitable for use in the Manhunt window.
"
" @return    list    One file per line.
"""
function! s:TransformQuickfixData()
  let l:quickfixList = getqflist()
  let l:textParts    = []

  " Extract commit metadata.
  for l:item in l:quickfixList
    let l:textParts += [split(l:item.text, s:summaryFormatSeparator)]
  endfor

  let l:longestName    = 0
  let l:longestMessage = 0

  " Find the length of the longest commit author name,
  " and longest commit message.
  for l:parts in l:textParts
    if strwidth(l:parts[1]) ># l:longestName
      let l:longestName = strwidth(l:parts[1])
    endif

    if strwidth(l:parts[2]) ># l:longestMessage
      let l:longestMessage = strwidth(l:parts[2])
    endif
  endfor

  let l:count          = 0
  let l:newBufferLines = ['[Working Copy]']

  " Build a list representing lines in the Manhunt buffer,
  " with pretty-aligned columns.
  for l:item in l:quickfixList
    let l:dateWithoutTimeZone = strpart(l:textParts[l:count][0], 0, 19)
    let l:paddedName          = s:Pad(l:textParts[l:count][1], l:longestName, 'right')
    let l:paddedMessage       = s:Pad(l:textParts[l:count][2], l:longestMessage, 'right')
    let l:fileName            = bufname(l:item.bufnr)

    let l:newBufferLines += [l:dateWithoutTimeZone . '    ' . l:paddedName . '    ' . l:paddedMessage . '    ' . l:fileName]

    let l:count += 1
  endfor

  return l:newBufferLines
endfunction

"""
" Instructs Manhunt to display a diff appropriate for the version of the file under the cursor.
"
" @param    string    a:intent    The user's intention when selecting the version. Can be any of:
"                                   'init'     = Initial version selection at Manhunt startup.
"                                   'switch'   = Selection occurs automatically during switch between Manhunt modes.
"                                   'this'     = Selection intented for no particular split.
"                                   'left'     = Selection intented for left diff split.
"                                   'right'    = Selection intented for right diff split.
"                                   'next'     = Selection intented for next version.
"                                   'previous' = Selection intented for previous version.
"""
function! s:SelectVersion(intent)
  call s:GotoManhuntSplit()

  let l:totalLines      = len(getbufline(s:manhuntBufferNumber, 1, '$'))
  let l:selectedLineNum = line('.')

  if s:mode ==# 'working'
    let s:selectedNewVersionLineNum = 1
    let s:selectedOldVersionLineNum = l:selectedLineNum

    if a:intent ==# 'init'
      let s:selectedOldVersionLineNum = 2
    endif
  elseif s:mode ==# 'pair'
    let s:selectedNewVersionLineNum = l:selectedLineNum
    let s:selectedOldVersionLineNum = l:selectedLineNum + 1
  elseif s:mode ==# 'pin'
    if a:intent ==# 'next'   ||   a:intent ==# 'previous'
      " In pin mode, ignore automatic up/down selections of next/previous version.
      return
    elseif a:intent ==# 'this'
      echoe 'Press L or R to select versions while in Manhunt pin mode.'
      return
    elseif a:intent ==# 'init'
      let s:selectedOldVersionLineNum = 2
    elseif a:intent ==# 'left'
      if l:selectedLineNum ># s:selectedOldVersionLineNum
        echoe 'Left selection cannot be older than right selection.'
        return
      endif

      let s:selectedNewVersionLineNum = l:selectedLineNum
    elseif a:intent ==# 'right'
      if l:selectedLineNum <# s:selectedNewVersionLineNum
        echoe 'Right selection cannot be older than left selection.'
        return
      endif

      let s:selectedOldVersionLineNum = l:selectedLineNum
    endif
  endif

  if s:selectedNewVersionLineNum ># l:totalLines
    let s:selectedNewVersionLineNum = l:totalLines
  endif

  if s:selectedOldVersionLineNum ># l:totalLines
    let s:selectedOldVersionLineNum = l:totalLines
  endif

  let l:newVersionLineText = getline(s:selectedNewVersionLineNum)
  let l:oldVersionLineText = getline(s:selectedOldVersionLineNum)

  let l:pattern            = 'fugitive:\/\/.*$'
  let l:newVersionFilePath = matchstr(l:newVersionLineText, l:pattern)
  let l:oldVersionFilePath = matchstr(l:oldVersionLineText, l:pattern)

  " If a file path cannot be found, the user must be selecting the [Working Copy].
  if l:newVersionFilePath ==# ''
    let l:newVersionFilePath = s:startFilePath
  endif

  if l:oldVersionFilePath ==# ''
    let l:oldVersionFilePath = s:startFilePath
  endif

  call s:DiffToggle(0)
  call s:ShowFile(l:newVersionFilePath, 'left')
  call s:ShowFile(l:oldVersionFilePath, 'right')
  call s:DiffToggle(1)

  call s:SetSigns(s:selectedNewVersionLineNum, s:selectedOldVersionLineNum)
endfunction

"""
" Sets the left and right signs in the Manhunt window.
"
" @param    integer    a:leftLineNum     The line number where the left sign should appear
" @param    integer    a:rightLineNum    The line number where the right sign should appear
"""
function! s:SetSigns(leftLineNum, rightLineNum)
  call s:GotoManhuntSplit()

  execute 'sign unplace * buffer=' . s:manhuntBufferNumber

  if a:leftLineNum ==# a:rightLineNum
    execute 'sign place 1 line=' . a:leftLineNum . ' name=' . s:manhuntLRSignName . ' buffer=' . s:manhuntBufferNumber
  else
    execute 'sign place 1 line=' . a:leftLineNum . ' name=' . s:manhuntLSignName . ' buffer=' . s:manhuntBufferNumber
    execute 'sign place 2 line=' . a:rightLineNum . ' name=' . s:manhuntRSignName . ' buffer=' . s:manhuntBufferNumber
  endif
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
