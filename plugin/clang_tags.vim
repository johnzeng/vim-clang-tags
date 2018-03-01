if &cp || exists("g:loaded_clang_tags")
   finish
else
    "start the clang tag server
    call clang_tags#do_cmd('start')
    call clang_tags#do_cmd('load')
endif
let g:loaded_clang_tags = 1

"au BufWritePost *.cc,*.cxx,*.hxx,*.c,*.cpp,*.h,*.hpp :call clang_tags#update()
command! -nargs=0 ClangTagsGrep :call clang_tags#grep('with_overriden')
command! -nargs=0 ClangTagsGrepNoVirtual :call clang_tags#grep('no_overriden')
command! -nargs=0 ClangTagsUpdate :call clang_tags#update()
command! -nargs=0 ClangTagsIndex :call clang_tags#index()
"command! -nargs=0 ClangTagsDef :call clang_tags#get_USR()
