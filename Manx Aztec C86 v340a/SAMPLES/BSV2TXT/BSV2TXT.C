/* BSV2TXT.C (C) Copyright Bill buckels 1990-2008. All rights reserved. */

/* converts bsaved text screens to text files */
/* stripping off the color attributes */
/* and truncating to 79 columns x 24 lines */
/* use commandline switches to override to 80 x 25 textfile with
   no carriage returns for ascii terminal-style full screen text
   without color attributes */

/* written by bill buckels in AZTEC C small model */

#include <stdio.h>
#include <fcntl.h>
#include <io.h>


main(argc, argv)
int argc;
char **argv;
{
    FILE *fp;
    int fh;
    unsigned char *bigbuffer;
    char buffer[128];
    char header[7];
    int limit = 24, col=79;
    int ctr=0,rows,columns;

    char *malloc();


    switch(argc){
        case 5: col=atoi(argv[4]);
                if (col<1||col>80)col = 79;

        case 4: limit=atoi(argv[3]);
                if(limit<1||limit>25)limit==24;
        case 3:

    	if((fh = open(argv[1],O_RDONLY)) == -1)break;
    		read(fh,header,7);
    		bigbuffer=(unsigned char *)malloc(4000);
    		read(fh,bigbuffer,4000)  ;
    		close(fh);

   			if((fp=fopen(argv[2],"w"))!=NULL){
   				for(rows=0;rows!=limit;rows++){
   					for(columns=0;columns<80;columns++){
       					buffer[columns]=bigbuffer[ctr];
       					ctr+=2;
       				}

   					buffer[col]=0x00;
   					if (col != 80) {
   						columns=col;
   						while(columns!=0){
							if(buffer[columns]==' '){
                        		buffer[columns]=0x00;
                        		columns--;
                    		}
                    		else columns=0;
                    	}
   						fprintf(fp,"%s\n",buffer);
					}
					else
						fprintf(fp,"%s",buffer);
   				}
   				fclose(fp);
   			}
   			free(bigbuffer);
   			break;

     	default:printf("USAGE is \"BSV2TXT [infile] [outfile] [lines-optional] [cols-optional]\"\n");
     }
     exit(0);
}
