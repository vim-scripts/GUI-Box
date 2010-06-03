" GUI Box
" Maintainer: David Munger
" Email: mungerd@gmail.com
" Version: 0.5.1


" TODO: doc color categories


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
if !exists("g:gui_fonts")
    let g:gui_fonts = [&guifont]
endif

if !exists("g:gui_colors")
	let g:gui_colors = ['=LIGHT=', 'default']
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
	20vnew +setlocal\ buftype=nofile Color\ Menu

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
	20vnew +setlocal\ buftype=nofile Font\ Menu

    call append('$', g:gui_fonts)
	call append('$', ["", "<Esc>: close", "<Space>: activate", "<Enter>: act+close"])
	0delete
	syntax match Comment /^<.*/
	syntax match Title /^=.*=$/

	map <buffer> <silent> <Esc> 	:bdelete<CR>
	map <buffer> <silent> <Space> 	:call <SID>font_menu_activate(0)<CR>
	map <buffer> <silent> <CR> 		:call <SID>font_menu_activate(1)<CR>
    call search('^' . &guifont . '$', 'w')

    setlocal cursorline nomodifiable
endfunction

function! s:font_menu_activate(close)

	if getpos('.')[1] > len(g:gui_fonts)
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

map <silent> <Plug>FontMenu :call <SID>font_menu()<CR>
" }}}

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
