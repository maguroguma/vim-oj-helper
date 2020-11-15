if executable('oj')
  " default configurations
  let g:ojhelper#submit_confirms = {
        \'atcoder': 'AtCoder: Submit OK?',
        \'codeforces': 'Codeforces: Submit OK?',
        \'yukicoder': 'yukicoder: Submit OK?',
        \}
  let g:ojhelper#lang_commands = {
        \'go': 'go run',
        \'python': 'python',
        \'bash': 'bash',
        \}
  let g:ojhelper#lang_extensions = {
        \'go': 'go',
        \'python': 'py',
        \'bash': 'sh',
        \}

  " update configurations by each user setting
  if exists("g:oj_helper_submit_confirms") && type(g:oj_helper_submit_confirms) == 4
    for s:key in keys(g:oj_helper_submit_confirms)
      let g:ojhelper#submit_confirms[s:key] = g:oj_helper_submit_confirms[s:key]
    endfor
  endif
  if exists("g:oj_helper_lang_commands") && type(g:oj_helper_lang_commands) == 4
    for s:key in keys(g:oj_helper_lang_commands)
      let g:ojhelper#lang_commands[s:key] = g:oj_helper_lang_commands[s:key]
    endfor
  endif
  if exists("g:oj_helper_lang_extensions") && type(g:oj_helper_lang_extensions) == 4
    for s:key in keys(g:oj_helper_lang_extensions)
      let g:ojhelper#lang_extensions[s:key] = g:oj_helper_lang_extensions[s:key]
    endfor
  endif

  " Read problem's URL from current buffer
  " This function assumes that *first matched* URL is the right URL.
  " This function returns a empty string if the current buffer has no URL.
  function! s:ReadProblemURLFromCurrentBuffer()
    let l:lines = getline(0, 10)
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

  function! g:ojhelper#DownloadSamples()
    let l:url = s:ReadProblemURLFromCurrentBuffer()

    " error handling
    if l:url ==# ''
      echoerr '[Error] The problem url is not found.'
      return
    endif

    let l:command = s:MakeSampleDLCommand(l:url)
    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction

  "
  " test samples
  "
  function! s:IsLanguageCommandDefined(lang)
    let l:lang_command = get(g:ojhelper#lang_commands, a:lang, '')
    if l:lang_command ==# ''
      return 0
    endif
    return 1
  endfunction

  function! s:DoesLanguageMatchFileExtension(lang)
    let l:cur_buf_ext = expand("%:e")
    let l:lang_ext = get(g:ojhelper#lang_extensions, a:lang, '')
    if l:lang_ext !=# l:cur_buf_ext
      return 0
    endif
    return 1
  endfunction

  function! s:MakeTestSamplesCommand(lang)
    let l:cur_buf_file = expand("%")
    let l:cur_buf_dir = expand("%:h")
    let l:sample_file_dir = l:cur_buf_dir . "/test"
    let l:lang_command = get(g:ojhelper#lang_commands, a:lang, '')

    let l:test_command = printf("oj test -c \"%s %s\" -d %s -t 4",
          \l:lang_command, l:cur_buf_file, l:sample_file_dir)
    return l:test_command
  endfunction

  function! g:ojhelper#TestSamples(lang)
    " error handling
    if !s:IsLanguageCommandDefined(a:lang)
      echoerr '[Error] The language command is not defined.'
      return
    endif
    if !s:DoesLanguageMatchFileExtension(a:lang)
      echoerr '[Error] The language does not match the current buffer file.'
      return
    endif

    let l:command = s:MakeTestSamplesCommand(a:lang)
    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction

  "
  " submit code
  "
  function! s:CaptureSiteName(url)
    let l:lower_url = tolower(a:url)
    for l:site_name in keys(g:ojhelper#submit_confirms)
      let l:matched_str = matchstr(l:lower_url, l:site_name)
      if l:matched_str != ''
        return l:site_name
      endif
    endfor
    return ''
  endfunction

  function! s:MakeSubmitCommand(url)
    let l:cur_buf_file = expand("%")
    let l:submit_command = printf("oj submit -y %s %s", a:url, l:cur_buf_file)
    return l:submit_command
  endfunction

  function! g:ojhelper#SubmitCode()
    let l:url = s:ReadProblemURLFromCurrentBuffer()

    " error handling
    if l:url ==# ''
      echoerr '[Error] The problem url is not found.'
      return
    endif

    " confirmation for each site
    let l:site_name = s:CaptureSiteName(l:url)
    let l:confirm_msg = get(g:ojhelper#submit_confirms, l:site_name, '')
    if l:confirm_msg != ''
      let l:ok = confirm(l:confirm_msg, "y yes\nn no")
      if l:ok != 1
        return
      endif
    endif

    " run
    let l:command = s:MakeSubmitCommand(l:url)
    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction
endif
