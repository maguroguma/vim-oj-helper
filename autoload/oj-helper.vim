if executable('oj')
  let g:oj_helper#submit_confirms = {
        \'atcoder': 'AtCoder: Submit OK?',
        \'codeforces': 'Codeforces: Submit OK?',
        \'yukicoder': 'yukicoder: Submit OK?',
        \}
  let g:oj_helper#lang_commands = {
        \'go': 'go run',
        \'python': 'python',
        \'bash': 'bash',
        \}
  let g:oj_helper#lang_extensions = {
        \'go': 'go',
        \'python': 'py',
        \'bash': 'sh',
        \}

endif

