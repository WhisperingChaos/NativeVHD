While developing Delete.cmd, a test revealed instance where diskpart detach command failed due to open file handle on vdisk.
This situation suggested that either simply mounting a vdisk's volume might establish an OS lock that would prohibit 
detach from successfully completing or once mounted some process holding an exclusive lock on a file that existed on this
disk might trigger detach's failure.  At the time the only way to clear this lock was to reboot the machine.  Therefore,
all the code tagged with a readme directive was generated believing a dismount was necessary in the situations previously
mentioned.  Therefore, the code was generated and at the time tested to iterate through all a vdisk's volumes and 
dismount each volume's mount point.  Unfortunately, further testing indicates simply executing a detach eliminates all
mount points and any locks on these points.  The code is being preserved, at least temporairily, if the detach failes
at some point to an open file handle.    