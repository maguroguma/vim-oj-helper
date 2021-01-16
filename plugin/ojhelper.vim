if executable('oj')
  " download samples command
  command! -nargs=0 OjDownloadSamples :call g:ojhelper#DownloadSamples()

  " submit code command
  command! -nargs=0 OjSubmitCode :call g:ojhelper#SubmitCode("")
  command! -nargs=0 OjSubmitCodeNoOpen :call g:ojhelper#SubmitCode("--no-open")

  " test command
  command! -nargs=1 OjLangCommandTest :call g:ojhelper#TestSamplesByLangCommand(<f-args>)
  command! -nargs=0 OjExecutableBinTest :call g:ojhelper#TestSamplesByExecutableBinary()
endif
