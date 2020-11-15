"=============================================================================
" vim-oj-helper
" Author: @maguroguma0712
" Last Change: 2020-11-16 02:11:39.

if executable('oj')
  """
  " Configurations
  """

  " default configurations
  let g:ojhelper#submit_confirms = {
        \'atcoder': 'AtCoder: Are you sure you want to submit?',
        \'codeforces': 'Codeforces: Are you sure you want to submit?',
        \'yukicoder': 'yukicoder: Are you sure you want to submit?',
        \'hackerrank': 'HackerRank: Are you sure you want to submit?',
        \}
  let g:ojhelper#lang_commands = {
        \'go': 'go run',
        \'python': 'python3',
        \'javascript': 'node',
        \}
  let g:ojhelper#lang_extensions = {
        \'go': 'go',
        \'python': 'py',
        \'javascript': 'js',
        \}
  let g:ojhelper#executable_binary = 'main'
  let g:ojhelper#search_url_s_line = 0
  let g:ojhelper#search_url_t_line = 10
  let g:ojhelper#testcase_dir_name = 'test'

  " update configurations by each user setting
  if exists("g:oj_helper_submit_confirms") && type(g:oj_helper_submit_confirms) == v:t_dict
    for s:key in keys(g:oj_helper_submit_confirms)
      let g:ojhelper#submit_confirms[s:key] = g:oj_helper_submit_confirms[s:key]
    endfor
  endif
  if exists("g:oj_helper_lang_commands") && type(g:oj_helper_lang_commands) == v:t_dict
    for s:key in keys(g:oj_helper_lang_commands)
      let g:ojhelper#lang_commands[s:key] = g:oj_helper_lang_commands[s:key]
    endfor
  endif
  if exists("g:oj_helper_lang_extensions") && type(g:oj_helper_lang_extensions) == v:t_dict
    for s:key in keys(g:oj_helper_lang_extensions)
      let g:ojhelper#lang_extensions[s:key] = g:oj_helper_lang_extensions[s:key]
    endfor
  endif
  if exists("g:oj_helper_executable_binary") && type(g:oj_helper_executable_binary) == v:t_string
    let g:ojhelper#executable_binary = g:oj_helper_executable_binary
  endif
  if exists("g:oj_helper_search_url_s_line") && type(g:oj_helper_search_url_s_line) == v:t_number
    let g:ojhelper#search_url_s_line = g:oj_helper_search_url_s_line
  endif
  if exists("g:oj_helper_search_url_t_line") && type(g:oj_helper_search_url_t_line) == v:t_number
    let g:ojhelper#search_url_t_line = g:oj_helper_search_url_t_line
  endif
  if exists("g:oj_helper_testcase_dir_name") && type(g:oj_helper_testcase_dir_name) == v:t_string
    let g:ojhelper#testcase_dir_name = g:oj_helper_testcase_dir_name
  endif

  """
  " Public functions
  """

  " DownloadSamples downloads problem's samples from a contest site.
  " This function assumes that a target URL is in a certain position in a
  " current buffer file.
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

  " SubmitCode submits a current buffer file.
  " This function assumes that a target URL is in a certain position in a
  " current buffer file.
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

    let l:command = s:MakeSubmitCommand(l:url)
    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction

  " TestSamplesByLangCommand executes sample testing for current buffer code.
  " This function assumes that called languages are mainly interpreted languages.
  function! g:ojhelper#TestSamplesByLangCommand(lang)
    " error handling
    if !s:IsLanguageCommandDefined(a:lang)
      echoerr '[Error] The language command is not defined.'
      return
    endif
    if !s:DoesLanguageMatchFileExtension(a:lang)
      echoerr '[Error] The language does not match the current buffer file extension.'
      return
    endif

    let l:command = s:MakeTestSamplesCommand(a:lang)
    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction

  " TestSamplesByExecutableBinary executes sample testing for a certain
  " executable binary file.
  function! g:ojhelper#TestSamplesByExecutableBinary()
    let l:cur_buf_dir = expand("%:h")
    let l:lang_exe_bin = l:cur_buf_dir . "/" . g:ojhelper#executable_binary

    " error handling
    let l:file_type = getftype(l:lang_exe_bin)
    if l:file_type !=# "file"
      echoerr '[Error] The executable binary file is not found.'
      return
    endif

    let l:sample_file_dir = l:cur_buf_dir . "/" . g:ojhelper#testcase_dir_name
    let l:command = printf("oj test -c \"%s\" -d %s -t 4",
          \l:lang_exe_bin, l:sample_file_dir)

    echo "[Run] " . l:command . "\n"
    call execute('vs')
    call execute('terminal ' . l:command)
  endfunction

  """
  " Private functions
  """

  " Read problem's URL from current buffer.
  " This function assumes that *first matched* URL is the right URL.
  " This function returns a empty string if the current buffer has no URL.
  function! s:ReadProblemURLFromCurrentBuffer()
    let l:lines = getline(g:ojhelper#search_url_s_line, g:ojhelper#search_url_t_line)
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

  " Make oj's download command.
  function! s:MakeSampleDLCommand(url)
    let l:cur_buf_dir = expand("%:h")
    let l:target_dir = l:cur_buf_dir . "/" . g:ojhelper#testcase_dir_name
    let l:dl_command = printf("oj download -d %s %s", l:target_dir, a:url)
    return l:dl_command
  endfunction

  " Make oj's submit command.
  function! s:MakeSubmitCommand(url)
    let l:cur_buf_file = expand("%")
    let l:submit_command = printf("oj submit -y %s %s", a:url, l:cur_buf_file)
    return l:submit_command
  endfunction

  " Make oj's test command.
  function! s:MakeTestSamplesCommand(lang)
    let l:cur_buf_file = expand("%")
    let l:cur_buf_dir = expand("%:h")
    let l:sample_file_dir = l:cur_buf_dir . "/" . g:ojhelper#testcase_dir_name
    let l:lang_command = get(g:ojhelper#lang_commands, a:lang, '')

    let l:test_command = printf("oj test -c \"%s %s\" -d %s -t 4",
          \l:lang_command, l:cur_buf_file, l:sample_file_dir)
    return l:test_command
  endfunction

  " Check whether a language command is defined or not.
  function! s:IsLanguageCommandDefined(lang)
    let l:lang_command = get(g:ojhelper#lang_commands, a:lang, '')
    if l:lang_command ==# ''
      return 0
    endif
    return 1
  endfunction

  " Check whether a language matches a file extension or not.
  function! s:DoesLanguageMatchFileExtension(lang)
    let l:cur_buf_ext = expand("%:e")
    let l:lang_ext = get(g:ojhelper#lang_extensions, a:lang, '')
    if l:lang_ext !=# l:cur_buf_ext
      return 0
    endif
    return 1
  endfunction

  " Capture a contest site name.
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
endif
