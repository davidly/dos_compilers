#include <stdio.h>
#include <stdlib.h>

main(int argc, char **argv)
{

   if (argc > 1) {
     unlink(argv[1]);
   }

   exit(0);

}