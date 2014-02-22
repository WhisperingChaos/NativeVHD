::-----------------------------------------------------------------------------
::-- Configuration file settings needed by the %~f0 script.
::-- The configuration setting routing is called from the same command processor as the %~f0 script
::-- Therefore, you can use other environment variables within this command process,
::-- like the user specific %%TEMP%% variable, and it will refer to the same one visible to the 
::-- script.
::--
::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
::-- as it will erase the values set by the script.
::-----------------------------------------------------------------------------
::-- The absolute path, without double quotes, to the ArgumentCheck routine.
set BIND_ARGUMENT=%~d0\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Argument
::
::-- The absolute path, enclosed in double quotes, to a file designated
::-- as a log.
set LOG_FILE="%~d0\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Logger\LogForSystem\Log.txt"

exit /b 0