" Use Vim settings, rather then Vi settings. This setting must be as early as
" possible, as it has side effects.
set nocompatible

" Leader
let mapleader = " "

set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Cucumber navigation commands
  autocmd User Rails Rnavcommand step features/step_definitions -glob=**/* -suffix=_steps.rb
  autocmd User Rails Rnavcommand config config -glob=**/* -suffix=.rb -default=routes

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown

  " Enable spellchecking for Markdown
  autocmd FileType markdown setlocal spell

  " Automatically wrap at 80 characters for Markdown
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80

  " Automatically wrap at 72 characters and spell check git commit messages
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType gitcommit setlocal spell

  " Allow stylesheets to autocomplete hyphenated words
  autocmd FileType css,scss,sass setlocal iskeyword+=-
augroup END

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" Color scheme
let g:solarized_termcolors=256
set background=light
set background=dark
set background=light
colorscheme github
highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Numbers
set number
set numberwidth=5

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Exclude Javascript files in :Rtags via rails.vim due to warnings when parsing
let g:Tlist_Ctags_Cmd="ctags --exclude='*.js'"

" Index ctags from any project, including those outside Rails
map <Leader>ct :!ctags -R .<CR>

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" vim-rspec mappings
nnoremap <Leader>t :call RunCurrentSpecFile()<CR>
nnoremap <Leader>s :call RunNearestSpec()<CR>
nnoremap <Leader>l :call RunLastSpec()<CR>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<space>

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" configure syntastic syntax checking to check on open as well as save
let g:syntastic_check_on_open=1
let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute \"ng-"]

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Always use vertical diffs
set diffopt+=vertical

" EMyth Specific

" Toggle the currently selected window to full screen and back
nnoremap <C-W>O :call MaximizeToggle()<CR>
nnoremap <C-W>o :call MaximizeToggle()<CR>
nnoremap <C-W><C-O> :call MaximizeToggle()<CR>

function! MaximizeToggle()
  if exists("s:maximize_session")
    exec "source " . s:maximize_session
    call delete(s:maximize_session)
    unlet s:maximize_session
    let &hidden=s:maximize_hidden_save
    unlet s:maximize_hidden_save
  else
    let s:maximize_hidden_save = &hidden
    let s:maximize_session = tempname()
    set hidden
    exec "mksession! " . s:maximize_session
    only
  endif
endfunction

"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark
map <leader>nf :NERDTreeFind<cr>
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => TSlime Rspec to Tmux 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rspec_command = 'call Send_to_Tmux("rspec {spec}\n")'
" command -nargs=? -complete=shellcmd W  :w | :call call Send_to_Tmux("load '".@%."';")
command -nargs=? -complete=shellcmd W  :w | :call Send_to_Tmux("load '".@%."';\n")
command -nargs=? -complete=shellcmd CR  :call Send_to_Tmux(".clear\n")


"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Teaspoon settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" map <Leader>j :w<CR> :call Send_to_Tmux("rake teaspoon\n")<CR>
command -nargs=? -complete=shellcmd TS  :call Send_to_Tmux("rake teaspoon\n")
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Screen settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:ScreenImpl = 'Tmux'
" let g:ScreenShellTmuxInitArgs = '-2'
" let g:ScreenShellInitialFocus = 'shell'
" let g:ScreenShellQuitOnVimExit = 0
" map <F5> :ScreenShellVertical<CR>
" map <F6> :ScreenShell<CR>
" command -nargs=? -complete=shellcmd W  :w | :call ScreenShellSend("load '".@%."';")
" map <Leader>r :w<CR> :call ScreenShellSend("rspec ".@% . ':' . line('.'))<CR>
" map <Leader>e :w<CR> :call ScreenShellSend("cucumber --format=pretty ".@% . ':' . line('.'))<CR>
" map <Leader>b :w<CR> :call ScreenShellSend("break ".@% . ':' . line('.'))<CR>
" 
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => CoffeeLint settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let coffee_linter = '/usr/local/bin/coffeelint'
" let coffee_lint_options = '-f /home/lmiller/Documents/my_dotfiles/coffeelint.json'
" Folding
autocmd BufNewFile,BufReadPost *.coffee setl foldmethod=indent
" Two-space indentation
autocmd BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab


" let g:syntastic_coffee_coffeelint_args="--file /home/lmiller/Documents/my_dotfiles/coffeelint.json"
" let g:syntastic_coffee_coffeelint_args="--file /Users/lmiller/Documents/my_dotfiles/coffeelint.json"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Crosshairs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" hi CursorLine   cterm=NONE ctermbg=235
" hi CursorColumn cterm=NONE ctermbg=235
hi CursorLine   cterm=NONE
hi CursorColumn cterm=NONE
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fast saving
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <leader>w :w!<cr>
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
" => bufExplorer plugin
""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>

""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
let MRU_Max_Entries = 400
map <leader>f :MRU<CR>

""""""""""""""""""""""""""""""
" => CTRL-P
""""""""""""""""""""""""""""""
let g:ctrlp_working_path_mode = 0

let g:ctrlp_map = '<c-f>'
map <c-b> :CtrlPBuffer<cr>

let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
" Remember info about open buffers on close
set viminfo^=%


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => tab mappings 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" map <a-1> 1gt
" map <C-2> 2gt
" map <C-3> 3gt
" map <C-4> 4gt
" map <C-5> 5gt
" map <C-6> 6gt
" map <C-7> 7gt
" map <C-8> 8gt
" map <C-9> 9gt
map <C-t> :tabnew<CR>
map <C-w> :tabclose<CR>
" 

function MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction

function MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr   = tabpagewinnr(a:n)
  let bufnam  = bufname(buflist[winnr - 1])
  " This is getting the basename() of bufname above
  let base    = substitute(bufnam, '.*/', '', '')
  let name    = a:n . ' ' . base
  return name
endfunction


set tabline=%!MyTabLine()
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Copy and paste 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" On OSX
" vmap <C-c> y:call system("pbcopy", getreg("\""))<CR>
" nmap <C-v> :call setreg("\"",system("pbpaste"))<CR>p
" On ubuntu (running Vim in gnome-terminal)
" The reason for the double-command on <C-c> is due to some weirdness with the X clipboard system.
vmap <C-c> y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>
nmap <C-v> :call setreg("\"",system("xclip -o -selection clipboard"))<CR>p
"
" set hlsearch
" These are the tweaks I apply to YCM's config, you don't need them but they might help.
" " YCM gives you popups and splits by default that some people might not like, so these should tidy it up a bit for you.
let g:ycm_add_preview_to_completeopt=0
let g:ycm_confirm_extra_conf=0
set completeopt-=preview

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => AG integration 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => gem ctags 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()
autocmd FileType ruby let &l:tags = pathogen#legacyjoin(pathogen#uniq(
      \ pathogen#split(&tags) +
      \ map(split($GEM_PATH,':'),'v:val."/gems/*/tags"')))

"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => javascript
" http://oli.me.uk/2013/06/29/equipping-vim-for-javascript/
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" breaks lines after a bracket has been inserted.
imap <C-c> <CR><Esc>O

let g:surround_{char2nr('=')} = "<%= \r %>"
let g:surround_{char2nr('-')} = "<% \r %>"



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: RRS-LMiller we need to make this into it's own plugin
" => force.com - settings
" //github.com/neowit/vim-force.com
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" breaks lines after a bracket has been inserted.
let g:apex_backup_folder = "/Users/lennymiller/code/emyth/apex/backup"
let g:apex_temp_folder = "/Users/lennymiller/code/emyth/apex/temp"
let g:apex_properties_folder = "/Users/lennymiller/code/emyth/apex/properties"
let g:apex_tooling_force_dot_com_path = "/Users/lennymiller/code/emyth/apex/lib/tooling-force.com-0.1.4.3.jar"

function! s:getVisualSelection()
  " Why is this not a built-in Vim script
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

"
" a:0 - number of arguments
" a:1 - query
" a:3 - SOQL
" a:4 - --format:csv
"
" s:apex('query','visual',true)
" s:apex('query','visual',true, '--format:csv')
function! s:ForceCLI(...)
  let parameterCount = a:0
  let apexQuery = a:1
  let apexMode  = a:2
  let apexSOQL = a:2
  let inVim = a:3
  let apexQuerySwitch = ' '

  if (parameterCount ==? '4')
    let apexQuerySwitch = a:4
  endif

  if (apexMode ==? 'visual')
    let apexSOQL = s:getVisualSelection()
  endif

  let apexCommand = "force ".apexQuery." \"".apexSOQL."\" ".apexQuerySwitch

  if inVim ==? 'true'
    let l:output = system(apexCommand)

    cexpr l:output
    caddexpr ""
    cwindow
  else
    call Send_to_Tmux(apexCommand." > apex_results\n;cat apex_results\n")
  endif
endfunction

function! s:ForceApex(...)
  let parameterCount = a:0
  let apexQuery = a:1
  let apexMode  = a:2
  let apexSOQL = a:2
  let inVim = a:3
  let apexQuerySwitch = ''

  if (parameterCount ==? '4')
    let apexQuerySwitch = a:4
  endif

  if (apexMode ==? 'visual')
    let apexSOQL = s:getVisualSelection()
  endif

  let apexCommand = "force ".apexQuery."\n".apexSOQL."\n".apexQuerySwitch

  call Send_to_Tmux(apexCommand)
endfunction

command -nargs=? -complete=shellcmd DeployApex  :call Send_to_Tmux("ant deploy_".split(expand('%:h'),'/')[0]."\n")
command -nargs=? -complete=shellcmd RetrieveApex  :call Send_to_Tmux("ant retrieve_".split(expand('%:h'),'/')[0]."\n")

command -nargs=? -complete=shellcmd ForceQuery :call  s:ForceCLI("query","visual","false")
command -nargs=? -complete=shellcmd ForceQueryToCsv :call  s:ForceCLI("query","visual","false","--format:csv")
command -nargs=? -complete=shellcmd ForceQueryInVim :call  s:ForceCLI("query","visual","true")
command -nargs=? -complete=shellcmd ForceQueryInVimToCsv :call  s:ForceCLI("query","visual","true","--format:csv")

command -nargs=? -complete=shellcmd ForceApex :call  s:ForceApex("apex","visual","false")

map <leader>dd :DeployApex<cr>
map <leader>rr :RetrieveApex<cr>
vmap <leader>11 :<BS><BS><BS><BS><BS>ForceQuery<cr><cr>
vmap <leader>22 :<BS><BS><BS><BS><BS>ForceQueryToCsv<cr><cr>
vmap <leader>33 :<BS><BS><BS><BS><BS>ForceQueryInVim<cr><cr>
vmap <leader>44 :<BS><BS><BS><BS><BS>ForceQueryInVimToCsv<cr><cr>

vmap <leader>55 :<BS><BS><BS><BS><BS>ForceApex<cr><cr>

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
