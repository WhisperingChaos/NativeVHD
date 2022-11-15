@echo on
setlocal

  if not defined METHOD_PATH (
    set METHOD_PATH=%~dp0\..\..\..\
  )
  if not exist "%~dp0\config.cmd" (
    echo Abort: Can't find expected config.cmd file: "%~dp0\config.cmd">&2
	exit /b 1
  )
  call "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 (
    exit /b %errorlevel%
  )
  if not exist %GEN_BASE_FILE_NAME% (
	echo original >%GEN_BASE_FILE_NAME%
  )
  call "%METHOD_PATH%GenNext.cmd" "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  set genNextFileName=
  call :GenName %GEN_BASE_FILE_NAME% 000000001 genNextFileName^
  || exit /b 1

  call :GenNameVerify %genNextFileName%^
  || exit /b 1

  call :GenContentsVerify %genNextFileName%^
  || exit /b 1

  call :GenTestReset %genNextFileName%^
  || exit /b 1

endlocal
exit /b 0


:GenName:
setlocal
set genCurrentPath=%~dp1
set genCurrentFileName=%~n1
set genCurrentFileExt=%~x1
set genSeqNumPadded=%2
set genFileNameRTN=%3
(
endlocal
set %genFileNameRTN%=^"%genCurrentPath%\%genCurrentFileName%_%genSeqNumPadded%%genCurrentFileExt%^"
exit /b 0
)


:GenNameVerify:
setlocal
set genNextPathFileNm=%1

  if not exist %genNextPathFileNm% (
    echo Abort: Failed to replicate GEN_BASE_FILE_NAME=%GEN_BASE_FILE_NAME% as %genNextPathFileNm%>&2
	exit /b 1
  )
endlocal
exit /b 0

  
:GenContentsVerify:
setlocal
set genNextPathFileNm=%1

  fc /b %GEN_BASE_FILE_NAME% %genNextPathFileNm%>nul
  if %errorlevel% NEQ 0 (
    echo Abort: Failed to replicate GEN_BASE_FILE_NAME=%GEN_BASE_FILE_NAME% as %genNextPathFileNm%>&2
	exit /b 1
  )
endlocal
exit /b 0


:GenTestReset:
setlocal
set genNextPathFileNm=%1

  del %GEN_BASE_FILE_NAME% >nul
  if %errorlevel% NEQ 0 (
    echo Abort: Failed to delete GEN_BASE_FILE_NAME=%GEN_BASE_FILE_NAME% while resetting test.>&2
	exit /b 1
  )
  del %genNextPathFileNm% >nul
  if %errorlevel% NEQ 0 (
    echo Abort: Failed to delete genNextPathFileNm=%genNextPathFileNm% while resetting test.>&2
	exit /b 1
  )
endlocal
exit /b 0