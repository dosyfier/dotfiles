" Indentation settings for using 2 spaces instead of tabs.
set softtabstop=2
set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
set shiftwidth=4
set tabstop=4

" NERDTree initial width
let g:NERDTreeWinSize=50
" Let NERDTree show hidden files
let g:NERDTreeShowHidden=1

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Press Ctrl-r after selecting some text in visual mode to template a
" '%s' Vim command to substitute it.
vnoremap <C-r> "hy:%s/<C-r>h/<C-r>h/gc<left><left><left>

" Thanks @alan-thompson
" Fix the difficult-to-read default setting for diff text highlighting. The
" bang (!) is required since we are overwriting the DiffText setting. The
" highlighting for "Todo" also looks nice (yellow) if you don't like the 
" "MatchParen" colors.
highlight! link DiffText Todo

" Always wrap long lines for display
set wrap

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Enable showing full path of current buffer on statusline
let g:spacevim_enable_statusline_bfpath=1

" Default to not read-only in vimdiff
set noro
