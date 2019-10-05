::-- create a locked file in given directory specified by %1.
::-- Don't release this lock until file %2 no longer exists.
:main:

call :pauseit %2 >"%~1\lockit.txt"
::-- designed to terminate process once complete 
exit 0


:pauseit:

::-- sleep to prevent hogging CPU 
timeout 1
if exist %1 goto pauseit

exit /b 0
