" auto-delete trailing spaces for certain filetypes
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    retab!
    exe "normal `z"
endfunc

function! FormatJSON(...)
    let code="\"
                \ var i = process.stdin, d = '';
                \ i.resume();
                \ i.setEncoding('utf8');
                \ i.on('data', function(data) { d += data; });
                \ i.on('end', function() {
                \     console.log(JSON.stringify(JSON.parse(d), null,
                \ " . (a:0 ? a:1 ? a:1 : 2 : 2) . "));
                \ });\""
    execute "%! node -e " . code
endfunction

function! s:align_lists(lists)
    let maxes = {}
    for list in a:lists
        let i = 0
        while i < len(list)
            let maxes[i] = max([get(maxes, i, 0), len(list[i])])
            let i += 1
        endwhile
    endfor
    for list in a:lists
        call map(list, "printf('%-'.maxes[v:key].'s', v:val)")
    endfor
    return a:lists
endfunction

function! s:btags_source()
    let lines = map(split(system(printf(
                \ 'ctags -f - --sort=no --excmd=number --language-force=%s %s',
                \ &filetype, expand('%:S'))), "\n"), 'split(v:val, "\t")')
    if v:shell_error
        throw 'failed to extract tags'
    endif
    return map(s:align_lists(lines), 'join(v:val, "\t")')
endfunction

function! s:btags_sink(line)
    execute split(a:line, "\t")[2]
endfunction

function! s:btags()
    try
        call fzf#run({
                    \ 'source':  s:btags_source(),
                    \ 'options': '+m -d "\t" --with-nth 1,4.. -n 1 --tiebreak=index',
                    \ 'down':    '40%',
                    \ 'sink':    function('s:btags_sink')})
    catch
        echohl WarningMsg
        echom v:exception
        echohl None
    endtry
endfunction

function! FindFunction(functionName) 
    execute "silent! /function \s*" . a:functionName
endfunction

" quickfixopenall.vim
"Author:
"   Tim Dahlin
"
"Description:
"   Opens all the files in the quickfix list for editing.
"
"Usage:
"   1. Perform a vimgrep search
"       :vimgrep /def/ *.rb
"   2. Issue QuickFixOpenAll command
"       :QuickFixOpenAll

function! QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction

command! QuickFixOpenAll call QuickFixOpenAll()
