:subroutine:
@echo off
setlocal

  echo select vdisk file=%MOUNT_VDISK_FILE%
  ::-- attach, even when it fails, will still set diskpart "disk" currency
  ::-- marking the disk associated to this vdisk as the current one.
  echo attach vdisk noerr
  echo select partition 1
  echo assign letter %MOUNT_VDISK_DRIVE_LETTER%
  echo detail vdisk
  echo detail disk
  
endlocal
exit /b 0
