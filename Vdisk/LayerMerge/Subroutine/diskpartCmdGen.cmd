:subroutine:
@echo off

  echo select vdisk file=%LAYER_MERGE_FILE%
  ::-- Can't merge if attached so first detach.  If not attached, detach will fail successfully permitting script to continue
  echo detach vdisk NOERR
  ::-- Merge current child with its immediate parent  
  echo merge vdisk depth=1
  
exit /b 0