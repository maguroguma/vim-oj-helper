if executable('oj')
  command! -nargs=0 OjDownload :call g:ojhelper#DownloadSamples()
  command! -nargs=0 OjSubmit :call g:ojhelper#SubmitCode()

  " e.g.: OjLangCommandTest go
  command! -nargs=1 OjLangCommandTest :call g:ojhelper#TestSamples(<f-args>)
  command! -nargs=0 OjExecutableBinTest :call g:ojhelper#TestSamplesByExecutableBinary()
endif
