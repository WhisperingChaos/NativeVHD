@echo off
:Subroutine:
setlocal
  ::-- Diskpart has a memory :: first attempt to detach vdisk before attempting to attach it.
  echo select vdisk file=%DISK_FORMAT_FILE%
  echo detach vdisk noerr
  echo select vdisk file=%DISK_FORMAT_FILE%
  ::-- extremely important to attach the vdisk so it becomes the current disk for both the partitioning and formatting commands. 
  echo attach vdisk
  ::-- unfortunately, after creating the paritition below, the windows hardware service may detect this vdisk with an unformated partition and ask that it be formatted. 
  echo create partition primary
  set DISK_FORMAT_VOLUME_LABEL_FORMAT=
  if defined DISK_FORMAT_VOLUME_LABEL (
    set DISK_FORMAT_VOLUME_LABEL_FORMAT=label=%DISK_FORMAT_VOLUME_LABEL%
  )
  echo format quick fs=NTFS %DISK_FORMAT_VOLUME_LABEL_FORMAT%
  echo detail disk
  echo detach vdisk
  
endlocal
exit /b 0