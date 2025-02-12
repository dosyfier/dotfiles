" Indentation settings for using 2 spaces instead of tabs.
set softtabstop=2
set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
set shiftwidth=4
set tabstop=4

" NERDTree initial width
let g:NERDTreeWinSize=30
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

" Always wrap long lines for display
set wrap

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Enable showing full path of current buffer on statusline
let g:spacevim_enable_statusline_bfpath=1

" Enable 'YouCompleteMe' as autocompletion plugin
let g:spacevim_enable_ycm=1

" Default to not read-only in vimdiff
set noro

" Allow modeline headers to activate declaratively specific vim syntax,
" regardless of rules defined for vim
set modeline
set modelines=5

" Make searches case-insensitive by default
set ignorecase
set smartcase

" Shortcut to open the current file into firefox
nnoremap <F12>f :exe ':silent !source ~/.dotfiles.env; source $DOTFILES_DIR/internal/aliases/distro.sh; if command -v wslpath > /dev/null; then firefox "file:///$(wslpath -m "%")"; else firefox "file:///%"; fi'<CR>

" If buffer modified, update any 'Last modified: ' in the first 20 lines.
" 'Last modified: Fri 04 Mar 2022 12:18:12 AM CET
" Restores cursor and window position using save_cursor variable.
function! UpdateLastModified()
  if &modified
    let save_cursor = getpos(".")
    let n = min([20, line("$")])
    keepjumps exe '1,' . n . 's#^\(.\{,10}Last modified: \).*#\1' .
          \ strftime('%a, %d %b %Y %H:%M:%S %z') . '#e'
    call histdel('search', -1)
    call setpos('.', save_cursor)
  endif
endfun
autocmd BufWritePre * call UpdateLastModified()

" Customize ALE linters warnings format (e.g. for shellcheck)
let g:ale_echo_msg_format='%severity%: %linter%: [%code] %%s'

" Necessary for the xmledit plugin
" (otherwise, the default '>' key mapping isn't working)
let g:xml_tag_completion_map = "<C-e>"

" Allow block folding in Vim editors
set foldmethod=indent

" Set up in offline mode by default
let g:spacevim_checkinstall=0

" Correct syntax highlight for Jinja2 template files
autocmd BufNewFile,BufRead *.jinja,*.j2 set filetype=jinja2

" Displays the syntax highlight group (and link, if there is one)
" of the word at the current cursor position
function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfunc

" Remove ^G characters from Nerd Tree view when running vim inside tmux
let g:NERDTreeNodeDelimiter = "\u00a0"
