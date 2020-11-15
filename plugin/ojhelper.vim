if executable('oj')
  command! -nargs=0 OjDownloadSamples :call g:ojhelper#DownloadSamples()
  command! -nargs=0 OjSubmitCode :call g:ojhelper#SubmitCode()
  command! -nargs=1 OjLangCommandTest :call g:ojhelper#TestSamplesByLangCommand(<f-args>)
  command! -nargs=0 OjExecutableBinTest :call g:ojhelper#TestSamplesByExecutableBinary()
endif
