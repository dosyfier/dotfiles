" Automatically set syntax for user data files
autocmd BufNewFile,BufRead user_data_* set filetype=bash
autocmd BufNewFile,BufRead user_data*_win,user_data*_win10,user_data*_windows,user_data_*.ps1 set filetype=powershell
