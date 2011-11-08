" function library -- some small general unrelated homeless functions ...
" File:		lib.vim (was: anwolib.vim)
" Created:	2007 Dec 07
" Last Change:	2011 Oct 30
" Rev Days:	51
" Author:	Andy Wokula <anwoku@yahoo.de>
" License:	Vim license

" Other libs to consider: {{{
"   genutils	Vimscript #197 (Hari Krishna Dara)
"   cecutil	Vimscript #1066 (DrChip)
"   tlib	Vimscript #1863 (Thomas Link)
"		http://github.com/tomtom/
"   TOVL	Vimscript #1963 (Marc Weber)
"		http://github.com/MarcWeber/theonevimlib
" }}}

" Changes: {{{
" 2010 Aug 15	nwo#lib#FitEcho() -> nwo#lib#FitStr()
" }}}

let g:nwo#lib#loaded = 1

let s:cpo_save = &cpo
set cpo&vim

" like extend({baselist}, {append}), but only insert missing items
" Notes:
" - the {append} list is changed, use copy() to protect it
" - duplicates from {append} are not removed
func! nwo#lib#ExtendUniq(baselist, append, ...) "{{{
    " Changed: 2009 Mar 04
    " {baselist}    (list)
    " {append}	    (list)
    " a:1	    index for insertion of {append}
    if a:0 == 0
	return extend(a:baselist, filter(a:append, 'index(a:baselist,v:val)==-1'))
    else
	return extend(a:baselist, filter(a:append, 'index(a:baselist,v:val)==-1'), a:1)
    endif
    return a:baselist
endfunc "}}}

" (in place) remove duplicates from a list (keep left-most), keep sort order
func! nwo#lib#Uniq(list) "{{{
    " Changed: 2009 Mar 05
    let len = len(a:list)
    let idx = len-1
    while idx >= 1
	if index(a:list, a:list[idx]) < idx
	    call remove(a:list, idx)
	endif
	let idx -= 1
    endwhile
    return a:list
endfunc "}}}

" original PairList from 10-05-2007; see also l9#zip()
" [1,2,3,4], [5,6,7] -> [[1,5], [2,6], [3,7]]
func! nwo#lib#PairList(list1, list2) "{{{
    " Changed: 2007 Dec 07
    try
	let idx = 0
	let result = []
	while 1
	    call add(result, [a:list1[idx], a:list2[idx]])
	    let idx += 1
	endwhile
    catch /:E684:/
	" list index out of range - ignore
	" bad style seduced by simplicity
    endtry
    return result
endfunc "}}}

" (flat copy) [[0], [1,2], [3]] -> [0,1,2,3]
func! nwo#lib#Flatten1(list) "{{{
    " Added: 16-10-2009
    let result = []
    for sublist in a:list
	call extend(result, sublist)
    endfor
    return result
endfunc "}}}

" (in place) [1,2,3,3,3] - [1,3,3,4] -> [2,3]
func! nwo#lib#Substract(list1, list2) "{{{
    for elem in a:list2
	let idx = index(a:list1, elem)
	if idx >= 0
	    call remove(a:list1, idx)
	endif
    endfor
    return a:list1
endfunc "}}}

" split a string at the first occurrence of whitespace (after non-
" whitespace); return a list with two elements
func! nwo#lib#Split1(str) "{{{
    " Changed: 2009 Mar 04
    let str = substitute(a:str, '^\s*\|\s*$', '', 'g')
    let spos = match(str, '\S\zs\s\+\S')
    if spos > 0
	let srhs = match(str, '\S', spos)
	return [str[: spos-1], str[srhs :]]
    else
	return [str, ""]
    endif
endfunc "}}}

" expand all hardtabs in {line} with given {tabstop} setting
func! nwo#lib#ExpandTabs(line, ...) "{{{
    " Changed: 2009 Feb 02
    " {line} - (string)
    " a:1 {tabstop} - (number) defaults to &tabstop
    " a:2 {modts} - virtcol for the start of {line}, 0-based
    let ts = a:0>=1 && a:1>=1 ? a:1 : &tabstop
    let modts = a:0>=2 ? a:2 : 0
    let splitline = split(a:line,'\t\t\@!\zs\|[^\t]\t\@=\zs')
    let nparts = len(splitline)
    let partidx = 0
    while partidx < nparts
	let part = splitline[partidx]
	if part[0] == "\t"
	    let nspc = ts - modts % ts
	    let modts = 0
	    let splitline[partidx] = repeat(" ", nspc + ts * (strlen(part)-1))
	else
	    let modts += strlen(part)
	endif
	let partidx += 1
    endwhile
    return join(splitline, "")
endfunc "}}}
func! nwo#lib#ExpandTabs_Mbyte(line, ...) "{{{
    " Changed: 2009 Feb 02
    " {line} - (string)
    " a:1 {tabstop} - (number) defaults to &tabstop
    " a:2 {modts} - virtcol for the start of {line}, 0-based
    let ts = a:0>=1 && a:1>=1 ? a:1 : &tabstop
    let modts = a:0>=2 ? a:2 : 0
    let splitline = split(a:line,'\t\t\@!\zs\|[^\t]\t\@=\zs')
    let nparts = len(splitline)
    let partidx = 0
    while partidx < nparts
	let part = splitline[partidx]
	if part[0] == "\t"
	    let nspc = ts - modts % ts
	    let modts = 0
	    let splitline[partidx] = repeat(" ", nspc + ts * (strlen(part)-1))
	else
	    let modts += nwo#lib#Strlen(part)
	endif
	let partidx += 1
    endwhile
    return join(splitline, "")
endfunc "}}}
"" Garbage: {{{
"" let fulletab = repeat(" ", ts)
"" let spaces = repeat(" ", nspc)
"" let nresttabs = strlen(part) - 1
"" while nresttabs > 0
""     let spaces .= fulletab
""     let nresttabs -= 1
"" endwhile
"" let splitline[partidx] = spaces
"}}}

" replace spaces with Tabs in {line} with given {tabstop} setting
func! nwo#lib#SpacesToTabs(line, ...) "{{{
    " Added: 2009 Oct 24
    " {line} - (string), must not contain Tabs (!)
    " a:1 {tabstop} - (number) defaults to &tabstop (also when 0 or less)
    " a:2 {modts} - virtcol for the start of {line}, 0-based
    let ts = a:0>=1 && a:1>=1 ? a:1 : &tabstop
    let modts = a:0>=2 ? a:2 : 0
    let splitline = split(a:line, '   \@!\zs\|[^ ]\%(  \)\@=\zs')
    let nparts = len(splitline)
    let partidx = 0
    while partidx < nparts
	let part = splitline[partidx]
	let plen = strlen(part)
	if part =~ '^  '
	    let irun = modts % ts + plen
	    if irun < ts || (modts%ts == ts-1 && plen <= ts)
		let modts += plen
	    else
		let nspc = irun - ts
		let ntabs = 1 + nspc / ts
		let modts = nspc % ts
		let splitline[partidx] =
		    \ repeat("\t", ntabs). repeat(" ", modts)
	    endif
	else
	    let modts += plen
	endif
	let partidx += 1
    endwhile
    return join(splitline, "")
endfunc "}}}
func! nwo#lib#SpacesToTabs_Mbyte(line, ...) "{{{
    " Added: 2009 Oct 24
    " {line} - (string), must not contain Tabs (!)
    " a:1 {tabstop} - (number) defaults to &tabstop
    " a:2 {modts} - virtcol for the start of {line}, 0-based
    let ts = a:0>=1 && a:1>=1 ? a:1 : &tabstop
    let modts = a:0>=2 ? a:2 : 0
    let splitline = split(a:line, '   \@!\zs\|[^ ]\%(  \)\@=\zs')
    let nparts = len(splitline)
    let partidx = 0
    while partidx < nparts
	let part = splitline[partidx]
	let plen = nwo#lib#Strlen(part)
	if part =~ '^  '
	    let irun = modts % ts + plen
	    if irun < ts || (modts%ts == ts-1 && plen <= ts)
		let modts += plen
	    else
		let nspc = irun - ts
		let ntabs = 1 + nspc / ts
		let modts = nspc % ts
		let splitline[partidx] =
		    \ repeat("\t", ntabs). repeat(" ", modts)
	    endif
	else
	    let modts += plen
	endif
	let partidx += 1
    endwhile
    return join(splitline, "")
endfunc "}}}

" strlen() for multi-byte strings
if exists("*strchars")
    func! nwo#lib#Strlen(str) "{{{
	" Added: 2011 Feb 05
	return strchars(a:str)
    endfunc "}}}
else
    func! nwo#lib#Strlen(str) "{{{
	" Added: 2009 Nov 19
	return strlen(substitute(a:str, ".", "x", "g"))
    endfunc "}}}
endif

func! nwo#lib#Let(val, expr, ...) "{{{
    " Added: 2011 Mar 31
    return eval(a:expr)
endfunc "}}}

func! nwo#lib#Rot13(str) "{{{
    " Changed: 2007 May 22
    let from = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    let to =   "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm"
    return tr(a:str, from, to)
endfunc "}}}

" available width for echoing a string in the Cmdline
func! nwo#lib#CmdlineWidth() "{{{
    " Changed: 2011 Feb 05
    if &cmdheight == 1
	let showcmd_off = &showcmd ? 11 : 0
	let laststatus_off = !&ruler || &laststatus==2 ? 0
	    \ : &laststatus==0 ? 19 : winnr('$')==1 ? 19 : 0
	return &columns - showcmd_off - laststatus_off - 1
    else
	return &columns
    endif
    " rule of thumb, former 17 for the ruler wasn't enough
    " has('cmdline_info') && has('statusline')
    " default 'rulerformat' assumed
    " should be merged with tlib#notify#*()
endfunc "}}}

" return {str} echo-able, cut it in the middle to avoid a Hit-Enter prompt
func! nwo#lib#FitStr(str) "{{{
    return nwo#lib#TruncStr(a:str, nwo#lib#CmdlineWidth())
endfunc "}}}
" obsolete:
func! nwo#lib#FitEcho(str) "{{{
    echo nwo#lib#FitStr(a:str)
endfunc "}}}

" if {str} is longer than {maxlen}, insert "..." in the middle; return the
" modified string
func! nwo#lib#TruncStr(str, maxlen) "{{{
    " Changed: 2009 Mar 03
    let len = strlen(a:str)
    if len <= a:maxlen
	return a:str
    endif
    if a:maxlen >= 4
	if a:maxlen >= 14
	    let dots = "..."
	    let amountl = (a:maxlen / 2) - 2
	    " it's good to see more of the end of the string
	else
	    let dots = ".."
	    let amountl = (a:maxlen / 2) - 1
	endif
	let amountr = a:maxlen - amountl - strlen(dots)
	let lpart = strpart(a:str, 0, amountl)
	let rpart = strpart(a:str, len-amountr)
	return strpart(lpart. dots. rpart, 0, a:maxlen)
    elseif a:maxlen <= 0
	return ""
    else
	return strpart(a:str, 0, a:maxlen)
    endif
endfunc "}}}

" like TruncStr(), but first apply a modified pathshorten():
" ('~/vimfiles/plugin/foo.vim', 20) -> '~/v/plugin/foo.vim'
func! nwo#lib#TruncFilename(filename, maxlen) "{{{
    " Changed: 2009 Mar 07
    if strlen(a:filename) <= a:maxlen
	return a:filename
    endif
    let filename = a:filename
    let pat = '[^\\/]\zs[^\\/:]\+[\\/]\@='
    while 1
	let blen = strlen(filename)
	let shorter = substitute(filename, pat,'','')
	if strlen(shorter) == blen || blen <= a:maxlen
	    break
	endif
	let filename = shorter
    endwhile
    return nwo#lib#TruncStr(filename, a:maxlen)
endfunc "}}}

" pattern to require an even number of backslashes before what follows
unlet! g:nwo#lib#notesc
let g:nwo#lib#notesc = '\%(\\\@<!\%(\\\\\)*\)\@<='
lockvar g:nwo#lib#notesc
" or: '\%(\%(^\|[^\\]\)\%(\\\\\)*\)\@<='

" escape magic characters in pat for a literal search
func! nwo#lib#MagicEscape(pat, ...) "{{{
    " Changed: 2009 Mar 03
    " a:1   fbc, extra search forward (/) or backward (?) character to be
    "	    escaped (default '/')
    let fbc = a:0>=1 ? a:1 : '/'
    return escape(a:pat, fbc. '\.*$^~[')
endfunc "}}}
" escape chars in the replacement part of a substitute
func! nwo#lib#ReplEscape(repl, ...) "{{{
    let s_sep = a:0>=1 ? a:1 : '/'
    return escape(a:repl, s_sep.'&~\')
endfunc "}}}
" escape chars in menu items
func! nwo#lib#MenuEscape(entry) "{{{
    return escape(a:entry, "\\. \t|")
endfunc "}}}
" escape chars for use within a collection (pattern)
func! nwo#lib#CollEscape(str) "{{{
    " /[{str}]
    " chars to escape: ] \ - ^
    return escape(a:str, ']\-^')
endfunc "}}}
" escape a '/' that isn't already escaped:
func! nwo#lib#SlashEscape(str, ...) "{{{
    " for use in :g/{str}/..., :vimgrep /{str}/ ...
    " a:1   character to be escaped (instead of '/')
    " a:2   escape character (instead of '\')
    if a:0 == 0
	if a:str !~ '/'
	    return a:str
	else
	    return substitute(a:str, g:nwo#lib#notesc.'\/', '\\&', 'g')
	endif
    else
	let esc_char = a:0>=2 ? a:2 : '\'
	let slashpat = nwo#lib#MagicEscape(a:1)
	if a:str !~ slashpat
	    return a:str
	else
	    return substitute(a:str, g:nwo#lib#notesc. slashpat,
		\ nwo#lib#ReplEscape(esc_char). '&', 'g')
	endif
    endif
endfunc "}}}
" return a notesc pattern for a given escape char
func! nwo#lib#NotEsc(esc_char) "{{{
    let ecpat = nwo#lib#MagicEscape(a:esc_char)
    return printf('\%%(%s\@<!\%%(%s%s\)*\)\@<=', ecpat,ecpat,ecpat)
endfunc "}}}

func! nwo#lib#GetPlaceHolder(str) "{{{
    " generate an arbitrary string that doesn't occur in {str}
    " tries J, JQ, ..., JQXELSZGNUBIPWDKRYFMTAHOVCJ, ...
    " TODO: custom 'ignorecase'
    let i = 9
    let plh = nr2char(65 + i)
    while a:str =~ plh
        let i = (i+7) % 26
        let plh .= nr2char(65 + i)
    endwhile
    return plh
endfunc "}}}

func! nwo#lib#FargsList(str) "{{{
    " added 2011 Jul 22
    com! -nargs=* TmpFargs let result = [<f-args>]
    exec "TmpFargs" a:str
    delcom TmpFargs
    return result
endfunc "}}}

func! nwo#lib#BG(varname, ...) "{{{
    if exists("b:". a:varname)
	return eval("b:". a:varname)
    elseif exists("g:". a:varname)
	return eval("g:". a:varname)
    elseif a:0 >= 1
	return a:1
    endif
    return 0
endfunc "}}}

" replacement for exists("g:{scriptname}#loaded"), when the side effect of
" loading the script is needed; Vim7.3 no longer loads the script
func! nwo#lib#Avail(varname) "{{{
    " Added: 2010 Aug 02
    " Changed: 2011 Apr 12
    if exists(a:varname)
	return 1
    endif
    try
	call eval(a:varname)
	return 1
    catch /:E121:/
	" undefined variable, script could not be loaded
	return 0
    endtry
    " only after misusage
    return -1
endfunc "}}}

func! nwo#lib#SoftTabstop(vcol) "{{{
    let fnb1vcol = indent(".") + 1
    " virtual column of first non-blank, 1-based
    return !&sta && &sts==0 ? &tabstop
	\ : &sta && a:vcol <= fnb1vcol ? &shiftwidth
	\ : &sts>0 ? &softtabstop : &tabstop
endfunc
" soft_ts can be
"	&tabstop (if nosmarttab and softtabstop=0 set),
"	&shiftwidth (if smarttab is set and the cursor is in the indent part
"	    of the line), or
"	&softtabstop (if softtabstop>0 and either nosmarttab set or the
"	    cursor is after the first non-blank in the line)
"	&tabstop (for the remaining case: smarttab set, softtabstop=0,
"	    cursor after first non-blank) "}}}


let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set fdm=marker ts=8:
