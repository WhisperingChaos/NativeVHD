@echo off
:main:

  for /D %%t in ("%~dp0\T???") do ( 
    call :testit "%%t"
  )

exit /b

:testit:

  call "%~1\run.cmd"

exit /b
