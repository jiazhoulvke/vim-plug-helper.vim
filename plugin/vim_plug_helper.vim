if exists("g:loaded_vim_plug_helper") || &cp
	finish
endif
let g:loaded_vim_plug_helper = 1

function! s:IsWindows()
	return has("win32") || has("win64")
endfunction

function! s:IsLocalPath(str)
	if match(a:str, '^[\/~].*') > -1
		return 1
	endif
	return 0
endfunction

function! s:IsMacOS()
	return has("mac") || has("macunix") || has("gui_mac")
endfunction

function! s:IsPartURL(str)
	if match(a:str, '\w\+\/\w\+') > -1
		return 1
	endif
	return 0
endfunction

function! s:IsPluginLine(str)
	if match(a:str, '^\s*Plug\s\+'."'".'\(.\{-}\)'."'") > -1
		return 1
	endif
	return 0
endfunction

function! VimPlugHelperOpenLink() 
	let curline = getline('.')
	if !s:IsPluginLine(curline)
		return
	endif
	let ml = matchlist(curline, '^\s*Plug\s\+'."'".'\(.\{-}\)'."'")
	if len(ml) == 0
		return
	endif
	let url = ml[1]
	if s:IsLocalPath(url) 
		let url = expand(url)
	elseif s:IsPartURL(url)
		let url = 'https://github.com/' . url
	endif
	if s:IsWindows()
		execute 'silent ! start ' . url
	elseif s:IsMacOS()
		call system('open ' . shellescape(url).' &')
	else
		call system('xdg-open ' . shellescape(url).' &')
	endif
endfunction

function! VimPlugHelperGotoConfig()
	let curcol = col('.')
	let curline = getline('.')
	if !s:IsPluginLine(curline)
		return
	endif
	let matched_plugin = curline
	let sline = curline
	let curlen = 0
	while 1
		let result = matchstr(sline, '\s*\(Plug\s\{-}'."'".'.\{-}'."'".'\)')
		if result == "" || curcol < curlen
			break
		endif
		let curlen = curlen + strlen(result)
		let matched_plugin  = result
		let sline = strpart(sline, strlen(result))
	endwhile
	" echo matched_plugin
	let ml = matchlist(matched_plugin, '\s*Plug\s\+'."'".'\(.\{-}\)'."'")
	if len(ml) == 0
		return
	endif
	if ml[1] == ''
		return
	endif
	let sl = split(ml[1], '/')
	let plugin_name = get(sl,len(sl)-1)
	let match_strs = []
	let match_strs = add(match_strs, ml[1])
	let match_strs = add(match_strs, plugin_name)
	if match(plugin_name, '.n\?vim$') > -1
		let match_strs = add(match_strs, substitute(plugin_name, '.n\?vim$','',''))
	endif
	" if match(plugin_name, '.nvim$') > -1
	" 	let match_strs = add(match_strs, substitute(plugin_name, '.nvim$','',''))
	" endif
	if match(plugin_name, '^vim-') > -1
		let npstr = substitute(plugin_name, '^vim-','','')
		let match_strs = add(match_strs, npstr)
		" if match(npstr, '.vim$') > -1
		" 	let match_strs = add(match_strs, substitute(npstr, '.vim$','',''))
		" endif
		" if match(npstr, '.nvim$') > -1
		" 	let match_strs = add(match_strs, substitute(npstr, '.nvim$','',''))
		" endif
	endif
	let ml = matchlist(plugin_name, '^vim-\(.\+\).n\?vim$')
	if len(ml)>0
		let match_strs = add(match_strs, ml[1])
	endif
	for match_str in match_strs
		let sr = search('^\s*"\s*'.match_str.'\s*:\?\s*{\+\d\?$', 'nwz')
		if sr > 0
			call cursor(sr+1, 1)
			break
		endif
	endfor
endfunction

function! VimPlugHelperGotoDefine()
	let sr = search('^\s*"\s*.\{-}\s*:\?\s*{\+\d\?$', 'bcnz')
	let cline = getline(sr)
	let ml = matchlist(cline, '^\s*"\s*\(.\{-}\)\s*:\?\s*{\+\d\?$')
	if len(ml) == 0
		return
	endif
	let match_str = ml[1]
	let match_strs = []
	if stridx(match_str, '/') == -1
		if match(match_str, '.n\?vim$') == -1
			let match_strs = add(match_strs, '.\+\/'.match_str.'.n\?vim')
		endif
		if match(match_str, '^vim-') == -1
			let match_strs = add(match_strs, '.\+\/'.'vim-'.match_str)
		endif
		if match(match_str, '.n\?vim$') == -1 && match(match_str, '^vim-') == -1
			let match_strs = add(match_strs, '.\+\/'.'vim-'.match_str.'.n\?vim')
		endif
	endif
	if stridx(match_str, '/') == -1
		let match_strs = add(match_strs, '.\+\/'.match_str)
	else
		let match_strs = add(match_strs, match_str)
	endif
	call reverse(match_strs)
	for match_str in match_strs
		let sr = search('\s*Plug\s\+'."'".match_str."'", 'bwz')
		if sr > 0
			call cursor(sr, 1)
			break
		endif
	endfor
endfunction

function! VimPlugHelperSwitch()
	let curline = getline('.')
	if s:IsPluginLine(curline)
		call VimPlugHelperGotoConfig()
	else
		call VimPlugHelperGotoDefine()
	endif
endfunction

function! s:Setting()
	nnoremap<silent><buffer> gl :call VimPlugHelperOpenLink()<CR>
	nnoremap<silent><buffer> gs :call VimPlugHelperSwitch()<CR>
endfunction

if !exists('g:vim_plug_helper_no_maps')
	au! BufRead,BufEnter init.vim,ginit.vim,.vimrc,_vimrc call s:Setting()
endif
