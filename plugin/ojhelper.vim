if executable('oj')
  command! -nargs=0 OjDownload :call g:ojhelper#DownloadSamples()
  " e.g.: OjTest go
  command! -nargs=1 OjTest :call g:ojhelper#TestSamples(<f-args>)
  command! -nargs=0 OjSubmit :call g:ojhelper#SubmitCode()
endif
