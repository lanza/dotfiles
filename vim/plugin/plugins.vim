" Syntastic ------ {{{
let g:syntastic_check_on_open = 1
let g:syntastic_always_populate_loc_list = 1

let g:syntastic_python_checkers = ['pylint', 'python']
let g:syntastic_swift_checkers = ['swiftpm', 'swiftlint']
let g:syntastic_haskell_checkers = ['ghc-mod', 'hdevtools']
let g:hdevtools_options = '-g -Wall'

" Allow toggling of syntastic errors list
" http://stackoverflow.com/questions/17512794/toggle-error-location-panel-in-syntastic
function! ToggleErrors()
  " Check the total number of open windows
  let l:old_last_winnr = winnr('$')
  " Attempt to close the location list
  lclose
  " If there are still the same number of windows
  " Open the errors list
  if l:old_last_winnr == winnr('$')
    Errors
  endif
endfunction
nnoremap <leader>e :call ToggleErrors()<cr>
" }}}

" python-mode
let g:pymode_breakpoint = 0

" delimitMate
" Currently doesn't work with vim-endwise
" https://github.com/tpope/vim-endwise/issues/11#issuecomment-38747137
let g:delimitMate_expand_cr = 1
let g:delimitMate_quotes = "\" '"

" Tab/Enter usage
" If the popup menu is open go back with shift-tab
inoremap <S-Tab> <C-R>=<SID>BackwardsTab()<CR>
function! s:BackwardsTab()
  if pumvisible()
    return "\<C-p>"
  endif

  return ''
endfunction

inoremap <silent> <Tab> <C-R>=<SID>TabWrapper()<CR>
function! s:TabWrapper()
  if pumvisible()
    return "\<C-y>"
  else
    if s:ForceTab() || empty(&omnifunc)
      return "\<Tab>"
    else
      return "\<C-x>\<C-o>"
    endif
  endif

  return "\<Tab>"
endfunction

" Check if you should use a tab based on special characters
let g:invalid_tab_chars = ['^', '\^', '\s', '#', '/', '\\', '*']
function! s:ForceTab()
  let l:column = col('.') - 1
  let l:lastchar = getline('.')[l:column - 1]
  let l:iskeychar = l:lastchar =~? '\k' || l:lastchar ==? '.'
  let l:invalidchar = index(g:invalid_tab_chars, l:lastchar) < 0
  return !(l:column > 0 && (l:iskeychar && l:invalidchar))
endfunction

" vim-markdown
let g:markdown_fenced_languages = [
      \ 'objc',
      \ 'ruby',
      \ 'sh',
      \ 'swift',
      \ 'vim',
      \ 'yaml'
    \ ]

" vim-sort-motion
let g:sort_motion_flags = 'ui'

" vim-gnupg
let g:GPGDefaultRecipients = ['0x4C7167F8']
let g:GPGPreferArmor = 1

" Twitvim
let g:twitvim_count = 50
let g:twitvim_allow_multiline = 1

" jedi.vim
let g:jedi#show_call_signatures = 0

let g:Illuminate_delay = 200
highlight illuminatedWord ctermbg=white ctermfg=black

" Netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_list_hide =
      \ netrw_gitignore#Hide()
      \ . ',^\./'
      \ . ',^\.git/'

function! s:PrintNeomakeResult()
  echom printf('%s exited with %d',
        \ g:neomake_hook_context.jobinfo.maker.name,
        \ g:neomake_hook_context.jobinfo.exit_code)
endfunction

augroup neomake_config
  autocmd!
  autocmd! BufWritePost * Neomake

  autocmd User NeomakeJobFinished call s:PrintNeomakeResult()
augroup END

let g:neomake_error_sign = {'text': '>>', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {'text': '>>', 'texthl': 'NeomakeWarningSign' }
let g:neomake_message_sign = {'text': 'm>', 'texthl': 'NeomakeMessageSign' }
let g:neomake_info_sign = {'text': 'i>', 'texthl': 'NeomakeInfoSign'}

let g:neomake_python_enabled_makers = []
let g:neomake_c_enabled_makers   = []
let g:neomake_cpp_enabled_makers = []
let g:neomake_ruby_enabled_makers = []
let g:neomake_java_enabled_makers = []
let g:neomake_swift_enabled_makers = ["swiftc"]
let g:neomake_open_list = 2
let g:neomake_verbose = 0

command! -nargs=+ Nrun call s:Nrun(<q-args>)
function! s:Nrun(args)
  let l:arguments = split(a:args)
  let l:executable = remove(l:arguments, 0)
  let l:arguments = join(l:arguments, ' ')

  let l:maker = {
        \ 'exe': l:executable,
        \ 'args': l:arguments,
        \ 'errorformat': &errorformat,
      \ }
  call neomake#Make(0, [l:maker])
endfunction

let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extra_conf.py'
let g:ycm_filetype_whitelist = {
      \ 'cpp': 1,
      \ 'python': 1,
    \ }

" Let clangd fully control code completion
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
let g:ycm_clangd_binary_path = '/usr/local/opt/llvm/bin/clangd'
let g:ycm_clangd_args = ['-log=verbose', '-pretty']

let g:highlightedyank_highlight_duration = 150

nnoremap <silent> <C-W>z :call zoom#toggle()<CR>

let s:lldb_projections = {
      \   "include/lldb/*.h": {"alternate": "source/{}.cpp"},
      \   "source/*.cpp": {"alternate": "include/lldb/{}.h"}
      \ }

let s:swift_projections = {
      \   "include/swift/*.h": {"alternate": "lib/{}.cpp"},
      \   "lib/*.cpp": {"alternate": "include/swift/{}.h"}
      \ }

let s:llvm_projections = {
      \   "include/llvm/*.h": {"alternate": "lib/{}.cpp"},
      \   "lib/*.cpp": {"alternate": "include/llvm/{}.h"}
      \ }

augroup custom_projectionist
  autocmd!

  autocmd User ProjectionistDetect
        \ if fnamemodify(getcwd(), ":t") == "lldb" |
        \   call projectionist#append(getcwd(), s:lldb_projections) |
        \ endif
  autocmd User ProjectionistDetect
        \ if fnamemodify(getcwd(), ":t") == "swift" |
        \   call projectionist#append(getcwd(), s:swift_projections) |
        \ endif
  autocmd User ProjectionistDetect
        \ if fnamemodify(getcwd(), ":t") == "llvm" |
        \   call projectionist#append(getcwd(), s:llvm_projections) |
        \ endif
augroup END

let g:gutentags_file_list_command = 'rg --files'
let g:gutentags_exclude_filetypes = ['gitcommit', 'gitconfig', 'gitrebase', 'gitsendemail', 'git']

let g:ale_linters = {
      \ 'python': ['pyls'],
      \ 'ruby': [],
      \ 'rust': ['rls', 'cargo'],
      \ 'sh': ['shellcheck'],
      \ 'swift': ['swiftpm'],
    \ }
let g:ale_fixers = {'rust': ['rustfmt']}
let g:ale_fix_on_save = 1
let g:ale_open_list = 1

let g:tmux_navigator_disable_when_zoomed = 1

let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

let g:formatdef_buildifierbzl = "'buildifier -type bzl'"
let g:formatdef_buildifierbuild = "'buildifier -type build'"
let g:formatdef_buildifierworkspace = "'buildifier -type workspace'"

augroup setup_buildifier
  autocmd!

  " TODO: This is broken if you have a build file and then a json file? idk
  autocmd BufNewFile,BufRead *.bzl let g:formatters_bzl = ['buildifierbzl']
  autocmd BufNewFile,BufRead BUILD,BUILD.bazel,*.BUILD,BUILD.* let g:formatters_bzl = ['buildifierbuild']
  autocmd BufNewFile,BufRead WORKSPACE let g:formatters_bzl = ['buildifierworkspace']

  autocmd BufWrite *.bzl,BUILD,BUILD.bazel,*.BUILD,BUILD.*,WORKSPACE :Autoformat
  " this is bad when working on llvm
  " autocmd BufWrite *.cpp,*.c,*.h :Autoformat
augroup END
