filetype plugin indent on
set formatoptions-=r
set formatoptions-=o
" https://gist.github.com/rbtnn/8540338 （一部修正）うまくいかないかな
augroup auto_comment_off
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END
" htmlようの補完きのうhttps://qiita.com/Zhirou/items/f533dd40fceff6249049より
augroup MyXML
    autocmd!
    autocmd Filetype html inoremap <buffer> /<CR> </<C-x><C-o><ESC>F>a<CR><ESC>O
    autocmd Filetype html inoremap <buffer> /<Tab> </<C-x><C-o><ESC>F>a
augroup END
set nowrap
set guifont=HackGen\ Console\ NF\ Bold\ 12
set hlsearch
set ignorecase
set smartcase
set backspace=

set autoindent

set ruler
set number
set relativenumber
set list
set wildmenu
set showcmd

set shiftwidth=4
set softtabstop=4
set expandtab
set tabstop=4
set smarttab
set clipboard&
set clipboard^=unnamedplus
set completeopt=menu,popup
filetype plugin indent on
syntax enable
" https://vim-jp.org/vim-users-jp/2009/10/08/Hack-84.htmlより
" Save fold settings.   
autocmd BufWritePost * if expand('%') != '' && &buftype !~ 'nofile' | mkview | endif
autocmd BufRead * if expand('%') != '' && &buftype !~ 'nofile' | silent loadview | endif
" Don't save options.
set viewoptions-=options

if has('vim_starting')
    " 挿入モード時に非点滅の縦棒タイプのカーソル
    let &t_SI .= "\e[6 q"
    " ノーマルモード時に非点滅のブロックタイプのカーソル
    let &t_EI .= "\e[2 q"
    " 置換モード時に非点滅の下線タイプのカーソル
    let &t_SR .= "\e[4 q"
endif
"
" dein.vim settings {{{
" install dir {{{
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" }}}

" dein installation check {{{
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif
" }}}

" begin settings {{{
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " .toml file
  let s:rc_dir = expand('~/.vim')
  if !isdirectory(s:rc_dir)
    call mkdir(s:rc_dir, 'p')
  endif
  let s:toml = s:rc_dir . '/dein.toml'

  " read toml and cache
  call dein#load_toml(s:toml, {'lazy': 0})

  " end settings
  call dein#end()
  call dein#save_state()
endif
" }}}

" plugin installation check {{{
if dein#check_install()
  call dein#install()
endif
" }}}

" plugin remove check {{{
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif
" }}}
set helplang=ja



function! BracketComplement(num) abort
    let LList = ["(", "[", "{"]
    let RList = [")", "]", "}"]
    let pos = col(".") - 1
    let str = getline(".")
    let tmpl = pos == 0 ? "" : str[:pos - 1]
    let tmpr = str[pos:]

    let out = ""
    let flg = 0
   "次の文字がOKリストの要素であれば括弧を補完する
    let OK = [' ', '', ')', ']', '}']
    for c in OK
        if tmpr[0] == c
            let flg = 1
        endif
    endfor
    if flg
        let tmpl = tmpl . LList[a:num] . RList[a:num]
    else
        let tmpl = tmpl . LList[a:num]
    endif
    let str = tmpl . tmpr
    call setline('.', str)
    call cursor(line("."), pos+2)
    return out
endfunction

function! BracketOut(num) abort
    let List = [')', ']', '}']
    let pos = col(".") - 1
    let str = getline(".")
    let tmpl = pos == 0 ? "" : str[:pos - 1]
    let tmpr = str[pos:]
    if str[pos] == List[a:num]
        call cursor(line("."), pos+2)
    else 
        let str = tmpl . List[a:num] . tmpr
        call setline('.', str)
        call cursor(line("."), pos+2)
    endif
    return ''
endfunctio

function! QuotationFunc(num) abort
    let List = ['"', "'"]
    let pos = col(".") - 1
    let str = getline(".")
    let tmpl = pos == 0 ? "" : str[:pos - 1]
    let tmpr = str[pos:]
    if str[pos] == List[a:num]
        call cursor(line("."), pos+2)
    else 
        let flg = 0
       "次の文字がOKリストの要素であれば括弧を補完する
        let OK = [' ', '', ')', ']', '}']
        for c in OK
            if tmpr[0] == c
                let flg = 1
            endif
        endfor
        if flg
            let tmpl = tmpl . List[a:num] . List[a:num]
        else
            let tmpl = tmpl . List[a:num]
        endif
        let str = tmpl . tmpr
        call setline('.', str)
        call cursor(line("."), pos+2)
    endif
    return ""
endfunction

function! DeleteParenthesesAdjoin() abort
    let pos = col(".") - 1
    let str = getline(".")
    let parentLList = ["(", "[", "{", "\'", "\""]
    let parentRList = [")", "]", "}", "\'", "\""]
    let cnt = 0

    let output = ""

   "カーソルが行末の場合
    if pos == strlen(str)
        return "\b"
    endif
    for c in parentLList
       "カーソルの左右が同種の括弧
        if str[pos-1] == c && str[pos] == parentRList[cnt]
            call cursor(line("."), pos + 2)
            let output = "\b"
            break
        endif
        let cnt += 1
    endfor
    return output."\b"
endfunction

function! NewLine() abort
    let cli = getline('.') "カーソル行
    if cli[col('.')-2] == "{" && cli[col('.')-1] == "}"
        return "\<Enter>\<Esc>\k\$\a\<Enter>"
    else
        return "\<Enter>"
    endif
endfunction


inoremap <silent> ( <C-r>=BracketComplement(0)<CR>
inoremap <silent> [ <C-r>=BracketComplement(1)<CR>
inoremap <silent> { <C-r>=BracketComplement(2)<CR>
inoremap <silent> ) <C-r>=BracketOut(0)<CR>
inoremap <silent> ] <C-r>=BracketOut(1)<CR>
inoremap <silent> } <C-r>=BracketOut(2)<CR>
inoremap <silent> " <C-r>=QuotationFunc(0)<CR>
inoremap <silent> ' <C-r>=QuotationFunc(1)<CR>
inoremap <silent> <BS> <C-r>=DeleteParenthesesAdjoin()<CR>
inoremap <silent> <Enter> <C-r>=NewLine()<CR>
inoremap <silent> <C-f> <Esc>l
