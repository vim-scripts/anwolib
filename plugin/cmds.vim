" File:		cmds.vim
" Created:	2010 Mar 04
" Last Change:	2011 Oct 30
" Rev Days:	3
" Author:	Andy Wokula <anwoku@yahoo.de>

" Basic general commands that should be part of vim (can be used in
" plugins).

" :KeepView {cmd}					{{{1
"
"   wrap command {cmd} with
"	:let save_view = winsaveview()
"	:{cmd}
"	:call winrestview(save_view)
" Goodies:
" - nesting is possible, restoring will only be done for the outer-most
"   invocation
" - handles error situations

com! -nargs=* -complete=command KeepView
    \ try| call cmds#SaveView()| exec <q-args>
    \| finally| call cmds#RestoreView()| endtry

" :With {setlocal-args} Do {cmd}			{{{1
"
"   execute {cmd} with options temporarily set to {setlocal-args}

com! -nargs=* With try| exec cmds#With(<q-args>)
		\| finally| call cmds#WithRestore()| endtry

" :InFunc[!] {cmd}					{{{1
com! -bang -range -nargs=+  InFunc  <line1>,<line2>call cmds#InFunc(<bang>0, <q-args>)

" :InFuncCount {cmd}					{{{1
com! -nargs=+ InFuncCount  call cmds#InFuncCount(<q-args>)

" :Fsnorm[!] {normal-cmds}				{{{1
com! -bang -nargs=+ Fsnorm  InFuncCount silent normal<bang> <args>

" " :KeepWin {cmd}					{{{1
" com! -nargs=* -complete=command KeepWin
"     \ try| call cmds#SaveWinnr()| exec <q-args>
"     \| finally| call cmds#RestoreWinnr()| endtry
