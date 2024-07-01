/* Error message functions */
/*   Copyright (c) Mix Software 1988    */

dosexterr(struct DOSERROR *buffer)
{
   union REGS reg;
   int intdos();
   reg.x.ax = 0x5900;
   reg.x.bx = 0;
   intdos(&reg,&reg);
   if (buffer == NULL) return reg.x.ax;
   buffer->exterror = reg.x.ax;
   buffer->class = reg.h.bh;
   buffer->action = reg.h.bl;
   buffer->locus = reg.h.ch;
   return buffer->exterror;
   }

perror(s)
char *s;
{
    fputs(s, stderr); fputc(':', stderr);
    fputs(strerror(NULL),stderr);
}

#define ERRmaxln 32
char *strerror(string)
   char *string;
{
   extern int errno;
   extern int sys_nerr;
   extern char *sys_errlist[];
   extern char *int_errlist[];
   static char unknown[] = "Error cause unknown\n";
   static char *buffer = NULL;
   char *msg;
   if (errno <= sys_nerr) msg = sys_errlist[errno];
   else {
      if (errno > 0x80 && errno < 0x97)
         msg = int_errlist[errno-0x81];
      else msg = unknown;
      }
   if (string == NULL) return msg;
   if (buffer == NULL) buffer = malloc(94+4+ERRmaxln);
   if (buffer == NULL) return NULL;
   strncpy(buffer,string,94);
   strcat(buffer,": ");
   strcat(buffer,msg);
   return buffer;
}

int     sys_nerr = 17;
char    *sys_errlist[] = {"No Errors\n",
                          "Invalid Function Number\n",
                          "File not Found\n",
                          "Path not Found\n",
                          "No More File Handles\n",
                          "File Access Denied\n",
                          "Invalid  File Handle\n",
                          "Memory Blocks Destroyed\n",
                          "Insufficient Memory\n",
                          "Invalid Block Address\n",
                          "Invalid Environment\n",
                          "Invalid Format\n",
                          "Invalid Access Code\n",
                          "Invalid Data\n",
                          "Invalid Drive\n",
                          "Can't Remove Current Directory\n",
                          "Not Same Device\n",
                          "No More Files\n"                 };

char    *int_errlist[] = {"Out of Stack\n",
                          "Out of Heap\n",
                          "Damaged Stack or Heap\n",
                          "Damaged Stack or Heap\n",
                          "Divide by Zero\n",
                          "Invalid Instruction\n",
                          "Damaged Stack or Heap\n",
                          "Damaged Stack or Heap\n",
                          "I/O Error\n",
                          "Error Cause Unknown\n",
                          "Attempt to Write Input\n",
                          "File Not Open\n",
                          "Attempt to Read Output\n",
                          "No Memory for File Buffer\n",
                          "Error Cause Unknown\n",
                          "Damaged Stack or Heap\n",
                          "Bad Digit in Number\n",
                          "Damaged Stack or Heap\n",
                          "Arithmetic Overflow\n",
                          "Error Cause Unknown\n",
                          "Arithmetic Underflow\n",
                          "Log of Negative Number\n",
                          "Sqrt of Negative Number\n" };

