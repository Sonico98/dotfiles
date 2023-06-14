" Set this to 0 to disable ultisnips for snippet handling
let s:using_snippets = 1
let g:ale_disable_lsp = 1
"---------------------"
"|       Plugin      |
"---------------------"
"=================================================="
 call plug#begin('~/.vim/plugged')
"Show file icons for many different plugins"
 	Plug 'kyazdani42/nvim-web-devicons'
"Show a filesystem tree view at the side"
" 	Plug 'kyazdani42/nvim-tree.lua'
	Plug 'nvim-neo-tree/neo-tree.nvim'
	Plug 'MunifTanjim/nui.nvim'
	Plug 'nvim-lua/plenary.nvim'
"Better looking and more functional tabs"
	Plug 'akinsho/bufferline.nvim'
"Use fzf for searches"
	Plug 'junegunn/fzf'
 	Plug 'junegunn/fzf.vim'
"Code Auto Completion"
 	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'OmniSharp/omnisharp-vim'
	Plug 'dense-analysis/ale'
"Use git inside nvim"
	Plug 'tpope/vim-fugitive'
"Ayu color scheme"
 	Plug 'Luxed/ayu-vim'
"Highlight color names"
 	Plug 'chrisbra/Colorizer'
"Better SQL syntax highlighting"
	Plug 'shmup/vim-sql-syntax'
"Add indentation to all lines"
 	Plug 'lukas-reineke/indent-blankline.nvim'
"Resize splits intuitively"
	Plug 'simeji/winresizer'
"Display a status line"
 	Plug 'nvim-lualine/lualine.nvim'
"Save files with root"
 	Plug 'lambdalisue/suda.vim'
	Plug 'sheerun/vim-polyglot'
"Zoxide - a faster cd"
	Plug 'nanotee/zoxide.vim'
"Easier surrounding text between characters"
	Plug 'kylechui/nvim-surround'
"Fancier highlighting"
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	Plug 'nvim-treesitter/nvim-treesitter-textobjects'
	Plug 'joeky888/Ass.vim'
"Code Snippets"
if s:using_snippets
	Plug 'SirVer/ultisnips'
	Plug 'honza/vim-snippets'
endif

 call plug#end()
"=================================================="

"-------------------"
"|      Theme      |
"-------------------"
"=================================================="
"Enable terminal 24bit colors"
set termguicolors

"Enable the ayu color scheme"
let ayucolor='dark'
set background=dark

"Define a custom active line color"
"(Light #FFFFFF & Dark#1e2933)"
"and numbers color"
" lua << EOF
" require 'ayu'.setup({
"   overrides = function()
"     if vim.o.background == 'dark' then
"       return { 
" 		  LineNr = {fg = '#b3b1ad'},
" 		  CursorLine = {bg = '#1e2933'},
" 		  CursorLineNR = {bg = '#1e2933', fg = '#e6b450'}
" 		  }
"     else
"       return {
" 		  LineNr = {fg = '#575f66'},
" 		  CursorLine = {bg = '#d8d8d8'},
" 		  CursorLineNR = {bg = '#d8d8d8', fg = '#ff9940'}
" 		  }
"     end
"   end})
" EOF


function! s:custom_ayu_colors()
  call ayu#hi('LineNr', 'ui_fg', '')
  call ayu#hi('CursorLine', '', 'extended_active_line')
  call ayu#hi('CursorLineNR', 'common_accent', 'extended_active_line')
endfunction

augroup custom_colors
  autocmd!
  autocmd ColorScheme ayu call s:custom_ayu_colors()
augroup END

colorscheme ayu

"Disable line underline"
highlight CursorLine cterm=NONE
highlight CursorLineNR cterm=NONE

"Override the colorscheme background color"
highlight Normal ctermbg=NONE guibg=NONE
highlight SignColumn ctermbg=NONE guibg=NONE
"=================================================="

"-------------------------"
"|      VIM Options      |
"-------------------------"
"=================================================="
"Show the characters being typed"
set showcmd

"Change vim title to be just [filename - VIM]"
set titlestring=%t\ -\ VIM
set title

set number
set relativenumber

"Comments in italics"
set t_ZH=^[[3m
set t_ZR=^[[23m
highlight Comment cterm=italic
highlight Comment gui=italic

"Restore last position in file"
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"Highlight the current line"
set cursorline

"Detect mouse movement"
set mousemoveevent

"Remember undo between sessions"
set undofile
set undodir=~/.vim/undodir

"Exit visual block mode inmediately"
set timeoutlen=1000 ttimeoutlen=0

"Set tab size"
set tabstop=4
set shiftwidth=4

"Soft wrap lines at char=80 for Markdown files"
au BufRead,BufNewFile *.md setlocal textwidth=0 wrapmargin=0 columns=80 wrap linebreak

"Automatically create directories on save"
function s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

"Enable better tabs"
lua << EOF
require('bufferline').setup{
	\ options = {
	mode = 'tabs',
	always_show_bufferline = false,
	diagnostics = 'coc',
	offsets = {
        {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true -- use a "true" to enable the default, or set your own character
        }
    },
	hover = {
		enabled = true,
		delay = 0,
		reveal = {'close'}
		}
	}
  \ }
EOF

"Start NvimTree"
"lua << EOF"
"require'nvim-tree'.setup {}"
"EOF"


lua << EOF
vim.opt.list = true

require("indent_blankline").setup {
    show_end_of_line = false,
}
EOF

"Automatically fold code"
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=0
augroup remember_folds
  autocmd!
  au BufWinLeave ?* mkview 1
  au BufWinEnter ?* silent! loadview 1
augroup END
" Function to permanently delete views created by 'mkview'"
function! MyDeleteView()
    let path = fnamemodify(bufname('%'),':p')
    " vim's odd =~ escaping for /
    let path = substitute(path, '=', '==', 'g')
    if empty($HOME)
    else
        let path = substitute(path, '^'.$HOME, '\~', '')
    endif
    let path = substitute(path, '/', '=+', 'g') . '='
    " view directory
    let path = &viewdir.'/'.path
    call delete(path)
    echo "Deleted: ".path
endfunction

" Command Delview (and it's abbreviation 'delview')"
command Delview call MyDeleteView()
" Lower-case user commands: http://vim.wikia.com/wiki/Replace_a_builtin_command_using_cabbrev
cabbrev delview <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Delview' : 'delview')<CR>

"Folding for C#"
au FileType cs set omnifunc=syntaxcomplete#Complete
au FileType cs set foldmethod=marker
au FileType cs set foldmarker={,}
au FileType cs set foldtext=substitute(getline(v:foldstart),'{.*','{...}',)
au FileType cs set foldlevelstart=2

"Enable using the mouse"
set mouse=a
"=================================================="

"----------------------"
"|      Keybinds      |
"----------------------"
"=================================================="
"Use ; instead of : for commands"
nnoremap ; :
vnoremap ; :
nnoremap : ;

"Toggle Neotree with Ctrl+n"
nnoremap <C-n> :Neotree filesystem left toggle<CR>
nnoremap <C-b> :Neotree buffers left toggle<CR>

"Access system clipboard with Ctrl+y/p"
noremap <C-y> "+y
noremap <C-p> "+p

"Quickly change tabs"
nnoremap <silent>H <Cmd>BufferLineCyclePrev<CR>
nnoremap <silent>L <Cmd>BufferLineCycleNext<CR>
 
"Move tabs"
nnoremap <silent><S-Left> <Cmd>tabmove-<CR>
nnoremap <silent><S-Right> <Cmd>tabmove+<CR>

"Delete a word backwards, properly"
nnoremap db dvb
nnoremap dvb db

"Search in the file using fzf"
nnoremap <C-/> :BLines<CR>

"Reload vimrc and airline"
noremap <F5> :source $MYVIMRC<CR>

"Alias SW to SudaWrite"
:command SW SudaWrite

"Move cursor in insert mode without the arrow keys"
inoremap <C-j> <Left>
inoremap <C-k> <Right>

"Automatically close brackets"
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
"=================================================="

"---------------------"
"|     Treesitter    |
"---------------------"
"=================================================="
lua << EOF
require'nvim-treesitter.configs'.setup {
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,
	-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
	additional_vim_regex_highlighting = false,
	disable = function(lang, buf)
        local max_filesize = 800 * 1024 -- 800 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
     },
	
  indent = {
    enable = true
  },
}
EOF
"=================================================="

"---------------------"
"|      Lualine      |
"---------------------"
"=================================================="
lua << EOF
require("lualine").setup({
	options = {
		theme = "ayu",
	},
	sections = {
	  lualine_c = {
		{
		  'filename',
		  file_status = true,
		  path = 3,
		  shorting_target = 40,
		  symbols = {
			modified = '[+]',
			readonly = '[-]',
			unnamed = '[No Name]',
		  }
		}
	  },
      lualine_b = {
		  'branch',
		  'diff',
		{
			'diagnostics',
			sources = { 'coc', 'ale', 'nvim_lsp' },
			sections = { 'error', 'warn', 'info', 'hint' },
			diagnostics_color = {
				error = 'DiagnosticError',
				warn  = 'DiagnosticWarn',
				info  = 'DiagnosticInfo',
				hint  = 'DiagnosticHint',
			},
			symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'},
			colored = true,
			update_in_insert = false,
			always_visible = false,
		}
	  }
	}
})
EOF
"=================================================="

"---------------------"
"|      coc.nvim      |
"---------------------"
"=================================================="
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=150

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-u> and <C-i> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-PageDown> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-PageDown>"
  inoremap <silent><nowait><expr> <C-PageDown> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  vnoremap <silent><nowait><expr> <C-PageDown> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-PageDown>"
  nnoremap <silent><nowait><expr> <C-PageUp> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-PageUp>"
  inoremap <silent><nowait><expr> <C-PageUp> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-PageUp> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-PageUp>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
"=================================================="

"----------------"
"|   Omnisharp  |"
"----------------"
"=================================================="
" OmniSharp: {{{
let g:OmniSharp_server_use_net6 = 1
let g:OmniSharp_selector_ui = 'fzf'
let g:OmniSharp_selector_findusages = 'fzf'
let g:OmniSharp_popup_position = 'peek'
if has('nvim')
  let g:OmniSharp_popup_options = {
  \ 'winblend': 30,
  \ 'winhl': 'Normal:Normal,FloatBorder:ModeMsg',
  \ 'border': 'rounded'
  \}
else
  let g:OmniSharp_popup_options = {
  \ 'highlight': 'Normal',
  \ 'padding': [0],
  \ 'border': [1],
  \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
  \ 'borderhighlight': ['ModeMsg']
  \}
endif
let g:OmniSharp_popup_mappings = {
\ 'sigNext': '<C-n>',
\ 'sigPrev': '<C-p>',
\ 'pageDown': ['<C-f>', '<PageDown>'],
\ 'pageUp': ['<C-b>', '<PageUp>']
\}

if s:using_snippets
  let g:OmniSharp_want_snippet = 1
endif

let g:OmniSharp_highlight_groups = {
\ 'ExcludedCode': 'NonText'
\}
" }}}
let g:ale_linters = {
\ 'cs': ['OmniSharp']
\}
"=================================================="

"----------------"
"|   UtilSnips  |"
"----------------"
"=================================================="
let g:UltiSnipsExpandTrigger="<C-i>"
let g:UltiSnipsJumpForwardTrigger="<A-k>"
let g:UltiSnipsJumpBackwardTrigger="<A-j>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "my_snippets"]
"=================================================="


"---------------------"
"|   Nvim-Surround   |"
"---------------------"
"=================================================="
lua << EOF
require("nvim-surround").setup({})
EOF
"=================================================="


"----------------"
"|   Neo-Tree   |"
"----------------"
"=================================================="
lua << EOF
require("neo-tree").setup({
	window = {
          position = "left",
          width = 40
	},
	hijack_netrw_behavior = "open_default",
    })
EOF
