" File:         cmds.vim
" Created:      2011 Jul 22
" Last Change:  2011 Oct 30
" Rev Days:     1

" :KeepView {{{1
" these function are not supposed to be called directly
"
if !exists("s:vist")
    let s:vist = {'depth': 0}
endif

func! cmds#SaveView()
    if s:vist.depth == 0
	let s:vist.view = winsaveview()
    endif
    let s:vist.depth += 1
endfunc

func! cmds#RestoreView()
    if s:vist.depth == 1
	call winrestview(s:vist.view)
	unlet s:vist.view
    endif
    let s:vist.depth -= 1
endfunc

" :With {{{1
let g:with_optstack = []

func! cmds#With(args)
    " opt=val opt invopt opt! opt& opt< opt+=val opt-=val opt^=val

    let savopt = []
    call insert(g:with_optstack, savopt)
    let got = {}

    let dopos = match(a:args, '\%(^\|\s\zs\)Do\>\C')

    if dopos == -1
	echomsg "Usage:  :With {setlocal arguments} Do {commands}"
	return ""
    elseif dopos >= 3
	for setarg in nwo#lib#FargsList(strpart(a:args, 0, dopos))
	    let optname = matchstr(setarg, '^\%(no\|inv\)\=\zs\a\+')
	    if !has_key(got, optname)
		try
		    let value = eval("&". optname)
		    call insert(savopt, [optname, value])
		    let got[optname] = 1
		catch /:E113:/
		    echoerr 'With: Unknown option:' optname
		    " leave function
		endtry
	    endif
	    exec "setlocal" escape(setarg, " \t\\")
	endfor
    endif
    return strpart(a:args, matchend(a:args, 'Do\s*', dopos))
endfunc

func! cmds#WithRestore()
    if !empty(g:with_optstack[0])
	for [optname, value] in g:with_optstack[0]
	    exec "let &l:". optname "= value"
	endfor
    endif
    call remove(g:with_optstack, 0)
endfunc

" :InFunc, :InFuncCount {{{1
" For command :InFunc.  Wrap a {cmd} (:substitute etc.) in a function to
" automatically restore the last search pattern and highlighting state
" afterwards.  With {bang}, ignore the range.
func! cmds#InFunc(bang, cmd) range
    if a:bang
	exec a:cmd
    else
	exec a:firstline.",".a:lastline. a:cmd
    endif
endfunc
func! cmds#InFuncCount(cmd)
    " 15-10-2008 For command :InFuncCount (purpose similar to :InFunc), but
    " suitable to wrap ":normal".  Ignores a range, but replaces "[N]" with
    " the count in {cmd} ("" if zero).  Can also restore Visual mode.
    call nwo#gvmap#vrestore()
    let cnt = v:count==0 ? "" : v:count
    try
	exec substitute(a:cmd, '\C\[N]', cnt, 'g')
    catch
	echohl ErrorMsg
	echomsg substitute(v:exception, '^Vim.\{-}:', '', '')
	echohl none
    endtry
endfunc

" :KeepWin {{{1

let s:kpwin = {'depth': 0}

func! cmds#SaveWinnr()
    let winvarname = "w:keepwin". s:kpwin.depth
    let {winvarname} = 1
    let s:kpwin.depth += 1
endfunc

func! cmds#RestoreWinnr()
    let s:kpwin.depth -= 1
    " w:keepwin0
    let wvname = "keepwin". s:kpwin.depth
    let winvarname = "w:". wvname
    if exists(winvarname)
	unlet {winvarname}
	return
    endif
    let widx = index(map(range(1,winnr("$")), 'getwinvar(v:val, wvname)'), 1)
    if widx < 0
	let restore_wnr = 0
	for tabnr in range(1, tabpagenr("$"))
	    let widx = index(map(range(1, tabpagewinnr(tabnr, "$")),
		\ 'gettabwinvar(tabnr, v:val, wvname)'), 1)
	    if widx >= 0
		let restore_wnr = widx + 1
		break
	    endif
	endfor
	if restore_wnr == 0
	    return
	endif
	exec tabnr. "tabnext"
    else
	let restore_wnr = widx + 1
    endif
    exec restore_wnr. "wincmd w"
    unlet! {winvarname}
endfunc
