if &cp || exists("g:loaded_clang_tags")
   finish
else
    "start the clang tag server
    call clang_tags#do_cmd('start')
endif
let g:loaded_clang_tags = 1

"au BufWritePost *.cc,*.cxx,*.hxx,*.c,*.cpp,*.h,*.hpp :call clang_tags#update()
au VimLeavePre * call clang_tags#do_cmd('stop')
command! -nargs=0 ClangTagsGrep :call clang_tags#grep()
command! -nargs=0 ClangTagsUpdate :call clang_tags#update()
"command! -nargs=0 ClangTagsDef :call clang_tags#get_USR()
