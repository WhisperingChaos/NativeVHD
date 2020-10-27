call "%~dp0\configLayerCreate.cmd"
if %errorlevel% neq 0 (
  echo Error encountered when executing configuration file: "%~dp0\configLayerCreate.cmd" >&2
  exit /b 1
)
::