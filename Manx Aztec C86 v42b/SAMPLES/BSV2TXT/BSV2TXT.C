/* converts bsaved text screens to text files */
/* stripping off the color attributes */
/* and truncating to 24 lines */

/* written by bill buckels 1990 in AZTEC C small model */

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <io.h>


main(int argc, char **argv)
{
    FILE *fp;
    int fh;
    unsigned char *bigbuffer;
    char buffer[128];
    char header[7];
    int limit = 24;
    int ptr=0,rows,columns;



    switch(argc){
        case 4: limit=atoi(argv[3]);
                if(limit<1||limit>25)limit==24;
        case 3:

    if((fh = open(argv[1],O_RDONLY)) == -1)break;
    read(fh,header,7);
    bigbuffer= malloc(4000);
    read(fh,bigbuffer,4000)  ;
    close(fh);

   if((fp=fopen(argv[2],"w"))!=NULL){
   for(rows=0;rows!=limit;rows++){
   for(columns=0;columns!=80;columns++){
       buffer[columns]=bigbuffer[ptr];
       ptr+=2;
       }
   columns=79;
   buffer[columns]=0x00;
   while(columns!=0){if(buffer[columns]==' '){
                        buffer[columns]=0x00;
                        columns--;
                        }
                     else columns=0;
                        }
   fprintf(fp,"%s\n",buffer);
   }
   fclose(fp);
   }
   free(bigbuffer);
   break;

     default :printf(
    "USAGE is \"BSV2TXT [infile] [outfile] [numberoflines-optional]\"\n");
     }
     exit(0);
}
