if executable('oj')
  " Read problem's URL from current buffer
  " This function assumes that *first matched* URL is the right URL.
  " This function returns a empty string if the current buffer has no URL.
  function! s:ReadProblemURLFromCurrentBuffer()
    let l:lines = getline(0, line("$"))
    for l:line in l:lines
      let l:record = split(l:line, ' ')
      for l:r in l:record
        let l:url = matchstr(r, '^\(http\|https\):.*$')
        if l:url != ''
          return l:url
        endif
      endfor
    endfor
    return ''
  endfunction

  "
  " download samples
  "
  function! s:MakeSampleDLCommand(url)
    let l:cur_buf_dir = expand("%:h")
    let l:target_dir = l:cur_buf_dir . "/test"
    let l:dl_command = printf("oj download -d %s %s", l:target_dir, a:url)
    return l:dl_command
  endfunction
  function! s:DownloadSamples(url)
    let l:command = s:MakeSampleDLCommand(a:url)
    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction

  command! -nargs=0 DownloadSamples :call s:DownloadSamples(s:ReadProblemURLFromCurrentBuffer())

  "
  " test samples
  "
  function! s:MakeTestSamplesCommand()
    let l:cur_buf_go = expand("%")
    let l:cur_buf_dir = expand("%:h")
    let l:sample_file_dir = l:cur_buf_dir . "/test"
    let l:test_command = printf("oj test -c \"go run %s\" -d %s -t 4", l:cur_buf_go, l:sample_file_dir)
    return l:test_command
  endfunction
  function! s:TestSamples()
    let l:command = s:MakeTestSamplesCommand()
    echo "[Run] " . l:command . "\n"
    " terminalコマンドで実行するテスト
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction
  function! s:BashTestSamples()
    let l:cur_buf_go = expand("%")
    let l:cur_buf_dir = expand("%:h")
    let l:sample_file_dir = l:cur_buf_dir . "/test"
    let l:test_command = printf("oj test -c \"bash %s\" -d %s -t 4", l:cur_buf_go, l:sample_file_dir)
    echo "[Run] " . l:test_command . "\n"
    " terminalコマンドで実行するテスト
    call execute('vs')
    call execute('terminal ' . l:test_command)
  endfunction

  " Go
  command! -nargs=0 TestCurrentBufferGoCode :call s:TestSamples()
  " Bash
  command! -nargs=0 BashTestCurrentBuffer :call s:BashTestSamples()

  "
  " submit code
  "
  function! s:IsHostCodeforce(url)
    " sample: https://codeforces.com/contest/1430/problem/A#
    let l:str = matchstr(a:url, '^\(http\|https\)://codeforces.com')
    return l:str
  endfunction
  function! s:MakeSubmitCommand(url)
    let l:cur_buf_go = expand("%")
    let l:submit_command = printf("oj submit -y %s %s", a:url, l:cur_buf_go)
    return l:submit_command
  endfunction
  function! s:SubmitCode(url)
    if s:IsHostCodeforce(a:url) != ''
      " check when submitting codes to Codeforces
      let l:ok = confirm('こどふぉだけどオーバーフロー大丈夫？', "y yes\nn no")
      if l:ok != 1
        return
      endif
    endif

    " run
    let l:command = s:MakeSubmitCommand(a:url)
    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction

  command! -nargs=0 SubmitCode :call s:SubmitCode(s:ReadProblemURLFromCurrentBuffer())
endif

" set wildoptions=pum
" set pumblend=20

inoremap <C-a>pd PrintfDebug("\n")

let g:sonictemplate_vim_template_dir = [
      \ '~/go/src/github.com/my0k/go-competitive/template'
      \]

