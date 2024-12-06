" Vim syntax file
" Language:           MVinl
" Maintainer:         Daniel Sierpinski
" Last Change:        Dec 04, 2024
" Version:            1
"
" Thanks to the authors of lisp.vim
" ---------------------------------------------------------------------
autocmd BufNewFile,BufRead *.mvnl set filetype=mvinl

let s:id = "[a-zA-Z_][a-zA-Z0-9_]*"

syn keyword mvinlKeyword style as def
execute 'syn match mvinlIdentifier "' . s:id . '"'
syn match mvinlNumber "[0-9]\+"
execute 'syn match mvinlSymbol ":' . s:id . '"'
syn match mvinlString "\"((?:\\.|[^\"\\])*)\""
execute 'syn match mvinlKeywordArg "' . s:id . ':"'
execute 'syn match mvinlGroup "@' . s:id . '"'
syn match mvinlComment "#.*\n"
syn match mvinlOper "[+\-*/%]" contained

unlet s:id

syn cluster mvinlValue contains=mvnilString,mvinlNumber,mvinlSymbol
syn cluster mvinlLambda contains=@mvinlValue,mvinlIdentifier,mvinlOper

" ---------------------------------------------------------------------
" Match polish notation:
syn region mvinlParen0           matchgroup=hlLevel0 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen1
syn region mvinlParen1 contained matchgroup=hlLevel1 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen2
syn region mvinlParen2 contained matchgroup=hlLevel2 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen3
syn region mvinlParen3 contained matchgroup=hlLevel3 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen4
syn region mvinlParen4 contained matchgroup=hlLevel4 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen5
syn region mvinlParen5 contained matchgroup=hlLevel5 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen6
syn region mvinlParen6 contained matchgroup=hlLevel6 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen7
syn region mvinlParen7 contained matchgroup=hlLevel7 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen8
syn region mvinlParen8 contained matchgroup=hlLevel8 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen9
syn region mvinlParen9 contained matchgroup=hlLevel9 start="`\=(" end=")" skip="|.\{-}|" contains=@mvinlLambda,mvinlParen0

hi mvinlOperType guifg=#970096 ctermfg=95

hi! link mvinlOper mvinlOperType
hi link mvinlKeyword Keyword
hi link mvinlIdentifier Type
hi link mvinlNumber Number
hi link mvinlSymbol Constant
hi link mvinlString String
hi link mvinlKeywordArg Define
hi link mvinlGroup Identifier
hi link mvinlComment Comment

hi def hlLevel0 ctermfg=red     guifg=red1
hi def hlLevel1 ctermfg=yellow  guifg=orange1
hi def hlLevel2 ctermfg=green   guifg=yellow1
hi def hlLevel3 ctermfg=cyan    guifg=greenyellow
hi def hlLevel4 ctermfg=magenta guifg=green1
hi def hlLevel5 ctermfg=red     guifg=springgreen1
hi def hlLevel6 ctermfg=yellow  guifg=cyan1
hi def hlLevel7 ctermfg=green   guifg=slateblue1
hi def hlLevel8 ctermfg=cyan    guifg=magenta1
hi def hlLevel9 ctermfg=magenta guifg=purple1

