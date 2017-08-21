if &cp || exists("g:loaded_clang_tags")
 finish
endif
let g:loaded_clang_tags = 1

au BufWritePost *.c,*.cpp,*.xcc,*.h,*.hpp :call clang_tags#update()
command! -nargs=0 ClangTagsGrep :call clang_tags#grep()
command! -nargs=0 ClangTagsUpdate :call clang_tags#update()
command! -nargs=0 ClangTagsDef :call clang_tags#get_USR()
