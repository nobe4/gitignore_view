if exists('g:gitignore_view') || &cp
  finish
endif

let s:gitignore_view = '0.0.1'

" Let the user specify which file he wants to use
" default is /tmp/gitignore_file
let s:gitignore_file = '/tmp/gitignore_file'
if exists('g:gitignore_file') || &cp
  let s:gitignore_file = g:gitignore_file
endif

" Create the file if it doesn't exist
function! s:CreateTmpGitignoreFile()
  if !filereadable(s:gitignore_file)
    silent exec "!touch ".s:gitignore_file
  endif
  new
endfunction

" Export the first line to the gitignore file
" TODO: work on multiple lines
function! s:ExportPattern()
  let l:line = getline(1)

  " echo 'a' > file
  " override the file content
  let l:export_command = "echo '".l:line."' > ".s:gitignore_file
  call system(l:export_command)
endfunction

function! s:ClearFile()
  " It seems that deleting lines with 2,$d changes the cursor posisiton
  " Instead, create an array of line('$') - 1 elements and call setline with it
  let l:current_line = 1
  let l:last_line = line('$')
  let l:reset_lines = []

  while l:current_line < l:last_line
    let l:reset_lines += ['']
    let l:current_line += 1
  endwhile

  call setline(2, l:reset_lines)
endfunction

" Reload the entered pattern
function! s:ReloadExcludedFiles()
  call <SID>ExportPattern()
  call <SID>ClearFile()

  " Call the git ls-files command and insert the result into the file
  let l:gitignore_command = 'git ls-files --others -i --exclude-from='.s:gitignore_file
  let l:result = systemlist(l:gitignore_command)

  call setline(2, l:result)
endfunction

" Entry pointm create the new buffer and register the Reload handler for
" inserted text
function! s:GitignoreBuffer()
  call <SID>CreateTmpGitignoreFile()
  autocmd CursorMovedI <buffer> :call <SID>ReloadExcludedFiles()
endfunction

" Register the user-available command
command! GitignoreView call <SID>GitignoreBuffer()
