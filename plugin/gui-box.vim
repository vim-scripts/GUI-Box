" GUI Box
" Maintainer: David Munger
" Email: mungerd@gmail.com
" Version: 0.6.1


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
	execute g:gui_box_width . 'vnew +setlocal\ buftype=nofile Color\ Menu'
	setlocal modifiable

    call append('$', g:gui_colors)
	call append('$', ["", "<Esc>: close", "<Space>: activate", "<Enter>: act+close"])
	0delete
	syntax match Comment /^<.*/
	syntax match Title /^=.*=$/

	map <buffer> <silent> <Esc> 	:bdelete<CR>
	map <buffer> <silent> <Space> 	:call <SID>color_menu_activate(0)<CR>
	map <buffer> <silent> <CR> 		:call <SID>color_menu_activate(1)<CR>
    call search('^' . g:colors_name . '$', 'w')

    setlocal cursorline nomodifiable
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
		bdelete
	endif
	execute 'colorscheme ' . color
endfunction

map <silent> <Plug>ColorMenu :call <SID>color_menu()<CR>
" }}}

" Font Menu {{{
function! s:font_menu()
	execute g:gui_box_width . 'vnew +setlocal\ buftype=nofile Font\ Menu'
	setlocal modifiable

    call append('$', g:gui_fonts)
	call append('$', ["", "<Esc>: close", "<Space>: activate", "<Enter>: act+close",
				\ "K/+: bigger", "J/-: smaller"])
	0delete
	syntax match Comment /^<.*/
	syntax match Title /^=.*=$/

	map <buffer> <silent> <Esc> 	:bdelete<CR>
	map <buffer> <silent> <Space> 	:call <SID>font_menu_activate(0)<CR>
	map <buffer> <silent> <CR> 		:call <SID>font_menu_activate(1)<CR>
	map <buffer> <silent> K 		:call <SID>font_menu_resize(0.5)<CR><Space>
	map <buffer> <silent> J 		:call <SID>font_menu_resize(-0.5)<CR><Space>
	map <buffer> <silent> + 		K
	map <buffer> <silent> - 		J
    
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

    setlocal cursorline nomodifiable
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
		bdelete
	endif
	execute 'set guifont=' . escape(font, ' ')
endfunction

function! s:font_menu_resize(delta)

	let font = getline('.')

	let size = matchstr(font, '[0-9\.]*$')

	if empty(size)
		" if no size, start with default size
		let newfont = font . ' ' . printf('%g', g:gui_default_font_size)
	else
		" change size
		let newsize = printf("%g", str2float(size) + a:delta)
		let newfont = substitute(font, escape(size, '.') . '$', escape(newsize, '.'), '')
	endif

	setlocal modifiable
	call setline('.', newfont)
	setlocal nomodifiable

endfunction

map <silent> <Plug>FontMenu :call <SID>font_menu()<CR>
" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
