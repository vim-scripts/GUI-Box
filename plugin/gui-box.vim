" GUI Box
" Maintainer: David Munger
" Email: mungerd@gmail.com
" Version: 0.6.2


if !has("gui_running")
    finish
endif

" Load Only Once {{{
if exists("g:gui_box_loaded")
	finish
endif

let g:gui_box_loaded = 1
" }}}

" Settings {{{
if !exists("g:gui_box_width")
    let g:gui_box_width = 22
endif

if !exists("g:gui_fonts")
    let g:gui_fonts = [&guifont]
endif

if !exists("g:gui_colors")
	let g:gui_colors = ['=LIGHT=', 'default']
endif

if !exists("g:gui_default_font_size")
	let g:gui_default_font_size = 9
endif
" }}}

" Menu Bar {{{
function! s:ToggleMenuBar()
    if &guioptions =~# 'm'
        set guioptions-=m
    else
        set guioptions+=m
    endif
endfunction

noremap <silent> <script> <Plug>ToggleMenuBar :call <SID>ToggleMenuBar()<CR>
" }}}

" Color Menu {{{
function! s:color_menu()

	" check if window already exists
	let winnr = bufwinnr(bufnr('Color Menu'))
	if winnr >= 0
		silent execute winnr . 'wincmd w'
		return
	endif

	execute g:gui_box_width . 'vnew Color\ Menu'
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap cursorline nospell

    call append('$', g:gui_colors)
	call append('$', ["", "<Esc>: close", "<Space>: activate", "<Enter>: act+close"])
	0delete
	syntax match PreProc	/^<.*/
	syntax match Title		/^=.*=$/

	map <buffer> <silent> <Esc> 	:bwipeout<CR>
	map <buffer> <silent> <Space> 	:call <SID>color_menu_activate(0)<CR>
	map <buffer> <silent> <CR> 		:call <SID>color_menu_activate(1)<CR>
	nnoremap <buffer> <silent> G	G4k
    call search('^' . g:colors_name . '$', 'w')

    setlocal nomodifiable
endfunction

function! s:color_menu_activate(close)

	if getpos('.')[1] > len(g:gui_colors)
		return
	endif

    let color = getline('.')

	if (empty(color) || color[0] == '=')
		return
	endif

	if (a:close)
		bwipeout
	endif
	execute 'colorscheme ' . color
endfunction

map <silent> <Plug>ColorMenu :call <SID>color_menu()<CR>
" }}}

" Font Menu {{{
function! s:font_menu()

	" check if window already exists
	let winnr = bufwinnr(bufnr('Font Menu'))
	if winnr >= 0
		silent execute winnr . 'wincmd w'
		return
	endif

	execute g:gui_box_width . 'vnew Font\ Menu'
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap cursorline nospell

    call append('$', g:gui_fonts)
	call append('$', ["", "<Esc>: close", "<Space>: activate", "<Enter>: act+close",
				\ "K/+: bigger", "J/-: smaller"])
	0delete
	syntax match PreProc	/.*:.*/
	syntax match Title		/^=.*=$/

	map <buffer> <silent> <Esc> 	:bwipeout<CR>
	map <buffer> <silent> <Space> 	:call <SID>font_menu_activate(0)<CR>
	map <buffer> <silent> <CR> 		:call <SID>font_menu_activate(1)<CR>
	map <buffer> <silent> K 		:call <SID>font_menu_resize(0.5)<CR><Space>
	map <buffer> <silent> J 		:call <SID>font_menu_resize(-0.5)<CR><Space>
	map <buffer> <silent> + 		K
	map <buffer> <silent> - 		J
	nnoremap <buffer> <silent> G	G6k
    
	if search('^' . &guifont . '$', 'w')
		let s:inserted_fonts = 0
	else
		" if font not found, try to match without size and insert line
		let font_str = &guifont
		while !search('^' . font_str, 'w') && font_str =~ '[ 0-9\.]$'
			let font_str = font_str[:-2]
		endwhile
		call append(line('.') - 1, &guifont)
		normal k
		let s:inserted_fonts = 1
	endif

    setlocal nomodifiable
endfunction

function! s:font_menu_activate(close)

	if getpos('.')[1] > len(g:gui_fonts) + s:inserted_fonts
		return
	endif

    let font = getline('.')

	if (empty(font) || font[0] == '=')
		return
	endif

	if (a:close)
		bwipeout
	endif
	execute 'set guifont=' . escape(font, ' ')
endfunction

function! s:font_menu_resize(increment)

	let font = getline('.')

	let size = matchstr(font, '\zs[0-9\.]*\ze\s*$')

	if empty(size)
		" if no size, start with default size
		let newfont = font . ' ' . printf('%g', g:gui_default_font_size)
	else
		" change size
		let newsize = printf("%g", str2float(size) + a:increment)
		let newfont = substitute(font, escape(size, '.') . '\s*$', escape(newsize, '.'), '')
	endif

	setlocal modifiable
	call setline('.', newfont)
	setlocal nomodifiable

endfunction

map <silent> <Plug>FontMenu :call <SID>font_menu()<CR>
" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
