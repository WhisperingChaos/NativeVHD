::-- see readme.txt
:subroutine:

  if not "%DISK_NUMBER%"=="undefined" (
    echo select disk %DISK_NUMBER%
    echo detail disk
  ) else (
    echo select Vdisk file=%DELETE_VHD_FILE% 
    echo detach vdisk noerr
  )

exit /b 0