extern int Udevice[];
/*
** Return "true" if fd is a device, else "false"
*/
isatty(fd) int fd; {
  return (Udevice[fd]);
  }
