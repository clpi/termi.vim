" NOTE: Custom terminal split toggle plugin
"       currently ready for personal (me) use only!

" TODO: 
"   - [ ] make rows prop. to win height
"   - [ ] make prev buf stop going to top when toggling term

" NOTE: Default termi row height
let g:termi_rows=14
" NOTE: Default termi terminal name
let g:termi_name="clpt"
" NOTE: Default termi split behavior
let g:termi_split='h'
" NOTE: Default termi shell
let g:termi_shell='/bin/zsh'
" NOTE: default termi comand
let g:termi_cmd=''
let g:termi_python_path="python3"
let g:termi_buffers={}

set term=$TERM
set termwinkey=<C-w>
set termwinsize=20x0

" NOTE: 
fun! s:TermFocus(tname=g:termi_name)
    silent! exe "b " a:tname 
endf

" NOTE: 
fun! s:TermInit()
    silent!
    set nobuflisted
    set filetype=termi
    set buftype=nofile
    set nonumber
    set signcolumn=no
    " setl laststatus=1
endf

" NOTE: 
fun! s:TermOpen(tname=g:termi_name, split=g:termi_split, rows=g:termi_rows, cmd="")
    silent!
    exe a:rows "split " bufwinnr(a:tname)
    exe s:TermInit()
    exe s:TermFocus(a:tname)
    if len(a:cmd) > 0 |exe s:TermExec(a:tname, a:cmd)|endif
endf

" NOTE: 
fun! s:TermNew(tname=g:termi_name,  split=g:termi_split,rows=g:termi_rows, cmd="")
    silent!
    exe "terminal ++rows=" . a:rows . " " . a:cmd
    exe s:TermInit()
    exe "f " a:tname
    if len(a:cmd) > 0 |exe s:TermExec(a:tname, a:cmd)|endif
endf

" NOTE: 
fun! s:TermHide(tname=g:termi_name)
    silent! exe bufwinnr(a:tname) . "hide"
endf

" NOTE: 
fun! s:TermClose(tname=g:termi_name)
    silent! exe bufwinnr(a:tname) . "hide"
endf

" NOTE: 
fun! s:TermRefresh(tname=g:termi_name)
    silent! exe s:TermClose(a:tname)
    silent! exe s:Term(a:tname)
endf

" NOTE: 
fun! s:TermExec(tname=g:termi_name, cmd="")
    silent!
    call term_sendkeys(bufwinnr(a:tname), a:cmd . "\<CR>")
endf

" NOTE: 
fun! TermExecLn(tname=g:termi_name)
    :%y \| 
    silent! call term_sendkeys(bufwinnr(a:tname), @")
endf

" NOTE: Base toggle command
fun! s:Term(
            \ tname=g:termi_name, 
            \ split=g:termi_split, 
            \ rows =g:termi_rows, 
            \ shell=g:termi_shell,
            \ cmd  =g:termi_cmd, 
            \ )
    let s:panw = bufwinnr(a:tname)
    let s:bufw = bufexists(a:tname)
    silent!
    if s:panw > 0 
        if a:cmd == ""
            exe s:TermHide(a:tname)
        else              
            exe s:TermExec(a:tname, a:cmd)
        endif
    elseif s:bufw > 0 | exe s:TermOpen(a:tname, a:split, a:rows, a:cmd)
    else              | exe s:TermNew(a:tname, a:split, a:rows, a:cmd)
    endif
endf

fun! s:TermArgs(...)
    let s:cmd   = g:termi_cmd
    let s:shell = g:termi_shell
    let s:rows  = g:termi_rows
    let s:split = g:termi_split
    let s:name  = g:termi_name
    if a:0 > 0
        for arg in a:000
            let s:akv=split(string(arg),'=')
            if     s:akv[0]=="cmd"  |s:cmd   = s:akv[1]
            elseif s:akv[0]=="rows" |s:rows  = s:akv[1]
            elseif s:akv[0]=='split'|s:split = s:akv[1]
            elseif s:akv[0]=='name' |s:name  = s:akv[1]
            elseif s:akv[0]=='shell'|s:shell = s:akv[1]
            " else 
            "     s:cmd += " " . s:akv[1]
            endif
        endfor
    endif
    return s:Term(s:name, s:split, s:rows, s:shell, s:cmd)
endf


command! -nargs=* Term 
    \ call <SID>TermArgs(<f-args>)

com! -nargs=+ TermExec
    \ call <SID>Term(g:termi_name,  g:termi_split, g:termi_rows, g:termi_shell,  <q-args>)
            " \ call <SID>Term(g:termi_name, 1, g:termi_rows, "zsh", <f-args> )
com! -nargs=0 TermClose
    \ call s:TermClose(g:termi_name)

com! -nargs=0 TermRefresh
    \ call s:TermRefresh(g:termi_name)

com! -nargs=0 TermExecLn
    \ call s:TermExecLn(g:termi_name)

nmap <silent><nowait> <space>ot <ESC>:Term<CR>

nnoremap <leader><cr> 

tnoremap <Esc> <C-W>N
tnoremap <ESC><ESC> <C-C><C-d>

nmap <silent><nowait> <C-p>      <ESC>:<C-U>Term<CR>
nmap <silent><nowait> <C-p>      <C-w>:<C-U>Term<CR>
nmap <silent> \t      :Term<CR>
tmap <silent> \t <C-w>:Term<CR>

nmap <silent>\p      :TermPy<CR>
tmap <silent>\p <C-w>:TermPy<CR>

nmap <silent> \T :term ++close<cr>
tmap <silent> \T <c-w>:term ++close<cr>

nmap <silent><nowait> <C-/> <ESC>:<C-u>Term<CR>
tmap <silent><nowait> <C-/> <C-w>:<C-u>Term<CR>

nmap <silent><nowait> <C-s-_> <ESC>:<C-u>Term<CR>
tmap <silent><nowait> <C-s-_> <C-w>:<C-u>Term<Cr>

" nmap <silent><nowait> <C-+> :TermPy<CR>
" tmap <silent><nowait> <C-+> <C-w>:TermPy<CR>

" nmap <silent><nowait> <C-=><C-=>      :Term<CR>
" tmap <silent><nowait> <C-=><C-=> <C-w>:Term<CR>

" nmap <silent><nowait> <C-=><C-p>      :TermPy<CR>
" tmap <silent><nowait> <C-=><C-p> <C-w>:TermPy<CR>

" nmap <silent><nowait> <C-=><C-n>      :TermNu<CR>
" tmap <silent><nowait> <C-=><C-n> <C-w>:TermNu<CR>

" nmap <silent><nowait> <C-=><C-s>      :TermBash<CR>
" tmap <silent><nowait> <C-=><C-s> <C-w>:TermBash<CR>

" nmap <silent><nowait> <C-=><C-f>      :TermFish<CR>
" tmap <silent><nowait> <C-=><C-f> <C-w>:TermFish<CR>

nmap <c-y>      <ESC>:<C-u>CocCommand terminal.Toggle<CR>
tmap <c-y> <C-w>:<C-u>CocCommand terminal.Toggle<CR>

" nmap <c-l>      :CocCommand terminal.Toggle<CR>
" tmap <c-l> <C-w>:CocCommand terminal.Toggle<CR>


nmap <silent><nowait> <C--> :Term<CR>
tmap <silent><nowait> <C--> <C-w>:Term<CR>

nmap <silent><nowait> <C-CR> <ESC>:<C-u>Term<CR>
tmap <silent><nowait> <C-CR> <C-w>:Term<CR>

nmap <silent><nowait> <c-t> :CocCommand terminal.Toggle<cr>
tmap <silent><nowait> <c-t> <C-w>:CocCommand terminal.Toggle<CR>

nmap -P :TermPy<CR>
nmap -B :TermBash<CR>
nmap -N :TermNu<CR>
nmap -r :terminal just run<CR>
nmap -b :terminal just build<CR>
nmap -c :terminal just check<CR>
" Start terminal in current pane
" nnoremap <M-CR> :call ChooseTerm("term-pane", 0)<CR>
"
tmap <C-q> <C-\><C-N> " NOTE: exits
tmap <C-p> <C-\><C-N> " NOTE: exits

tmap <C-n> <C-w>N     " Normal
tmap <C-BS> <C-w>N    " Normal

" tmap <ESC> <C-w>N
tmap <C-o> <C-\><C-N>

tnoremap   <silent> jj <C-\><C-N>" NOTE: normal mode
tnoremap   <silent> kj <C-\><C-N> "NOTE: exists"

tmap <C-;> <C-W>:
tnoremap   <silent> ;;     <C-w>:
tnoremap   <silent> ;k     <C-w><C-k>
tnoremap   <silent> ;<tab> <C-w><C-w>
tnoremap   <silent> ;c     <C-w><C-c>
tnoremap   <silent> ;/     <C-w><C-/>

nmap -r :Term just run<CR>
nmap -b :Term just build<CR>
nmap -c :Term just check<CR>

tmap <space><space>k <C-w>kk
tmap <space>kk <C-w>kk
tmap <space>qq <C-w>c

tmap <ESC> <C-w><C-n>
tmap <ESC><ESC> <C-d>


tmap <silent><nowait> <C-n> <C-w>k<ESC>:Term<CR>
tmap <silent><nowait> <C-k> <C-w>k<ESC>
tmap <silent><nowait> <C-j> <C-w>k  
tmap <silent><nowait> <C-l> <C-w>:quit<CR>
tmap <silent><nowait> <C-=> <C-w>N

augroup TermiStyle
    au!
    autocmd BufRead FileType termi hi guibctermfg=white 
    autocmd BufRead FileType termi hi ctermbg=DarkGrey 
    autocmd BufRead FileType termi hi ctermfg=white 
    autocmd BufRead FileType termi hi guifg=white
    autocmd BufRead FileType termi hi guibg=#101825
augroup END

nnoremap <nowait> g<CR>    <ESC>:<C-u>TermExec<SPACE>
nnoremap <nowait> <space><CR>    <ESC>:<C-u>TermExec<SPACE>
nnoremap <silent><nowait> g<space> <ESC>:<C-u>Term<CR>
nnoremap <silent><nowait> <space>tc <ESC>:<C-u>Term<CR>

