if !argc()
  " open a Tree if no file was specified
  autocmd vimenter * execute 'NvimTreeToggle' | execute "normal \<C-w>l" | execute ':q' | execute ':bdelete 1'
else
  " open filler Tree file | toggle Tree | move tab to left-most position | focus on second tab
  autocmd vimenter * tab sview ~/.nerdtree | tabm 0 | execute 'NvimTreeToggle' | execute ':tabn'
endif
