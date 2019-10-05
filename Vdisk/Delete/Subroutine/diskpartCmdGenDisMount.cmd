::-- see readme.txt
:subroutine:

  echo select vdisk file=%DELETE_VHD_FILE%
  echo attach vdisk noerr
  echo select volume=%DISMOUNT_VOLUME_NUMBER%
  echo remove all dismount noerr
  ::-- detach the vdisk as this might be last dismount.  A vdisk
  ::-- must be detached to eliminated OS handle that would prevent
  ::-- its deletion.  This also unifies special case where vdisk
  ::-- doesn't have volumes (not partitioned or not formatted).
  echo detach vdisk

exit /b 0