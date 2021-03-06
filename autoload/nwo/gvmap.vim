" Vim autoload script - help a mapping to work in several modes
" File:         gvmap.vim
" Created:      2009 Apr 27
" Last Change:  2011 May 31
" Rev Days:     11
" Author:	Andy Wokula <anwoku@yahoo.de>
" License:	Vim License, see :h license
" Version:      0.1

" 2009 Nov 20	mode(1) was added in Vim7.2; try-block removed
" 2010 Mar 28	gvmode#mode_no() merged into gvmap#mode()

" These two functions support creating a mapping that works transparently
" for both Normal and Visual mode (and Operator pending mode).
" An example is at EOF.

" TODO
" - gvmap#count(): Vim bug?  a count for an <expr> map is not cleared for
"   the next <expr> map

if v:version >= 702

func! nwo#gvmap#mode(...)
    let s:lastmode = mode(1)
    let s:count = v:count >= 1 ? v:count : ""
    if a:0 == 0 || s:lastmode !=# "no"
        return ":"
    elseif a:1 ==# "i"
        return 'v:'
    elseif a:1 ==# "l"
        return 'V:'
    endif
    echomsg "nwo#gvmap#mode(): invalid argument:" a:1
    return ":"
endfunc

else    " v:version < 702
" E118: Too many arguments for function: mode

func! nwo#gvmap#mode(...)
    let s:lastmode = mode()
    let s:count = v:count >= 1 ? v:count : ""
    return ":"
endfunc

endif

" :normal! gv
" 31-05-2011 s:lastmode is returned just in case it will be needed a little
" longer
func! nwo#gvmap#vrestore()
    if exists("s:lastmode")
	let lmode = s:lastmode
	if s:lastmode =~# "^i\\=[vV\<C-V>]"
	    normal! gv
	endif
	unlet s:lastmode
	return lmode
    endif
    return ""
endfunc
" prepare for "(insert) VISUAL", will it be "iv"?

" get the count ("" if v:count was zero); not recommended, use only when
" v:count gets lost before it's needed
func! nwo#gvmap#count()
    return s:count
endfunc

func! nwo#gvmap#lastmode()
    if exists("s:lastmode")
	return s:lastmode
    else
	return ""
    endif
endfunc

finish

" ----------------------------------------------------------------------

" Your Script:
" define and use '<SID>:' in place of ':'
noremap <expr> <SID>: nwo#gvmap#mode()

" some mapping:
map <script> <F8> <SID>:<C-U>call MyFunc()<CR>

func MyFunc()
    " restore Visual mode (only) when <F8> was pressed in Visual mode:
    call nwo#gvmap#vrestore()
    " calling this earlier is usually better
    ...
endfunc

