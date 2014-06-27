function! s:Manhunt()
  silent! Glog
  vsplit
  cwindow
  execute "silent! normal! \<c-w>Jmzj0viWhhy\<c-w>t\<c-w>l:diffoff\<CR>:edit \<c-r>\"\<CR>:diffthis\<CR>\<c-w>h:diffthis\<CR>gg]czz\<CR>\<c-w>b`z:delmarks z\<CR>"

  nnoremap <buffer> <CR> mz0viWhhy<c-w>t:diffoff<CR>:edit <c-r>"<CR><c-w>b:silent! normal! j<CR>0viWhhy<c-w>t<c-w>l:diffoff<CR>:edit <c-r>"<CR>:diffthis<CR><c-w>h:diffthis<CR>gg:silent! normal! ]czz<CR><c-w>b`z:delmarks z<CR>
  nnoremap <buffer> j jmz0viWhhy<c-w>t:diffoff<CR>:edit <c-r>"<CR><c-w>b:silent! normal! j<CR>0viWhhy<c-w>t<c-w>l:diffoff<CR>:edit <c-r>"<CR>:diffthis<CR><c-w>h:diffthis<CR>gg:silent! normal! ]czz<CR><c-w>b`z:delmarks z<CR>
  nnoremap <buffer> k kmz0viWhhy<c-w>t:diffoff<CR>:edit <c-r>"<CR><c-w>b:silent! normal! j<CR>0viWhhy<c-w>t<c-w>l:diffoff<CR>:edit <c-r>"<CR>:diffthis<CR><c-w>h:diffthis<CR>gg:silent! normal! ]czz<CR><c-w>b`z:delmarks z<CR>
endfunction

execute "command! Manhunt :call s:Manhunt()"
