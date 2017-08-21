function! clang_tags#get_offset()
    return eval(line2byte(line('.')) + col('.')) - 1
endfunction

function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

let g:clang_tags#root_file = '.ct.pid'
let g:clang_tags#command = 'clang-tags'

function! clang_tags#find_root_dir(dir)
    let ldir = a:dir
    while 1
        if filereadable(ldir . '/' . g:clang_tags#root_file)
            break
        else
            let ndir = fnamemodify(ldir, ':h')
            if ndir == ldir
                echoerr "Root file not found. Are you sure clang-tags server is running?"
                break
            endif
            let ldir = ndir
        endif
    endwhile
    return ldir
endfunction

function! clang_tags#do_cmd(cmd)
    let oldwd = getcwd()
    exec 'chdir ' . clang_tags#find_root_dir(oldwd)
    if(a:cmd == "update")
        call system(g:clang_tags#command . ' ' . a:cmd . '&')
        let res = ""
    else
        let res = split(system(g:clang_tags#command . ' ' . a:cmd), '\n')
    endif
    exec 'chdir ' . oldwd
    return res
endfunction

function! clang_tags#get_USR()
    let path = expand('%:p')
    let offset = clang_tags#get_offset()
    let res = clang_tags#do_cmd('find-def ' . path . ' ' . offset)
    echom "find def is done;"
    for i in res
        echom i
        let line = Strip(i)
        if line =~ "^USR: "
            echom "USR is found"
            return line[5:]
        endif
    endfor
    return ""
endfunction

function! clang_tags#grep()
    let def = substitute(clang_tags#get_USR(), "\\$", '\\\$', '')
    echom 'res is :'.def

    if strlen(def) > 0
        let loclist = []
        let res = clang_tags#do_cmd('grep "' . def . '"')
        let cwd = clang_tags#find_root_dir(getcwd())
        echom "grep is done"
        let last_item = {'filename': '', 'lnum': '0'}
        for i in res[1:]
            echom i
            let t = split(i, ':')
            let item = {'filename' : cwd . '/' . t[0], 'lnum' : t[1], 'text' : join(t[2:], ':')}
            if(item['filename'] == last_item['filename'] && item['lnum'] == last_item['lnum'])
                continue
            else
                call add(loclist, item)
            endif
            let last_item = item
        endfor
        call setloclist(0, loclist)
        if len(loclist) > 0
            exec "lopen"
        else
            echom "No results"
        endif
    else
        echom "No symbol"
    endif
endfunction

function! clang_tags#update()
    echom "updated"
    call clang_tags#do_cmd('update')
endfunction

