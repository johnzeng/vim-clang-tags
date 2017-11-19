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
                call clang_tags#do_cmd("start")
                return clang_tags#find_root_dir(a:dir)
            endif
            let ldir = ndir
        endif
    endwhile
    return ldir
endfunction

function! clang_tags#do_cmd(cmd)
    if("start" == a:cmd)
        call system(g:clang_tags#command.' '.a:cmd)
        return
    endif
    let oldwd = getcwd()
    exec 'chdir ' . clang_tags#find_root_dir(oldwd)
    let res = split(system(g:clang_tags#command . ' ' . a:cmd), '\n')
    exec 'chdir ' . oldwd
    if(1 == len(res) && -1 != match(res[0], 'Connection refused'))
        call clang_tags#do_cmd('clean')
        call clang_tags#do_cmd('start')
        call clang_tags#do_cmd('load')
        return clang_tags#do_cmd(a:cmd)
    endif
    return res
endfunction

function! clang_tags#get_USR_for_grep()
    echom 'now get most specific def'
    let path = expand('%:p')
    let offset = clang_tags#get_offset()
    let res = clang_tags#do_cmd('find-def ' . path . ' ' . offset . ' -m')
    
    let retLine = ""
    let retVirtual = ""
    for i in res
        let line = Strip(i)
        if line =~ "^USR: "
            let retLine = line[5:]
        endif
        if line =~ "^isVirtual: "
            let retVirtual = line[11:]
"            return { 'line':retLine, 'isVirtual':retVirtual}
            return [ retLine, retVirtual ]
        endif
    endfor
"    return { 'line':retLine, 'isVirtual':retVirtual}
    return [ retLine, retVirtual ]
endfunction

function! clang_tags#get_USR()
    echom 'now get def'
    let path = expand('%:p')
    let offset = clang_tags#get_offset()
    let res = clang_tags#do_cmd('find-def ' . path . ' ' . offset)
    for i in res
        let line = Strip(i)
        if line =~ "^USR: "
            return line[5:]
        endif
    endfor
    return ""
endfunction

if !exists('g:clang_tags_force_update_every_query')
    let g:clang_tags_force_update_every_query = 1
endif

fun clang_tags#ListYesOrNo(A,L,P)
    return ['yes', 'no']
endfunction

function! clang_tags#grep(overriden_or_not)
    if(1 == g:clang_tags_force_update_every_query)
        call clang_tags#update()
    endif
    let [defLine, isVirtual] = clang_tags#get_USR_for_grep()

"    let def = substitute(defLine, "\\$", '\\\$', 'g')
    let def = defLine

    let cmd_sufix = " "
    if(isVirtual == "1")
        if "with_overriden" == a:overriden_or_not
            let cmd_sufix = " -o"
        endif
    endif

    if strlen(def) > 0
        let loclist = []
        echom 'now searching references, please wait...'
        let res = clang_tags#do_cmd("grep \'" . def . "\' " . cmd_sufix)
        let cwd = clang_tags#find_root_dir(getcwd())
        let last_item = ""
        for i in res[1:]
            if(i == last_item)
                continue
            else
                call add(loclist, i)
                let last_item = i
            endif
        endfor

        cgete loclist
        copen
    else
    endif
endfunction

function! clang_tags#update()
    echom 'now update clang tags, please wait'
    call clang_tags#do_cmd('update')
endfunction

function! clang_tags#update()
    echom 'now create index of clang tags, please wait'
    call clang_tags#do_cmd('load')
    call clang_tags#do_cmd('index')
endfunction

