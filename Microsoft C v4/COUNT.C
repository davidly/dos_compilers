#include <stdio.h>
#include <io.h>
#include <ctype.h>
#include <string.h>

#define        BUFFSIZE        512     /* Small buffer for debugging   */
#define TRUE   1
#define FALSE  0
#define        FACTOR  1.1     /* Vowels per syllable in typical file  */

/* Conditional operator prevents divide by zero        */

#define WPS    (float)words / (sentences ? sentences : 1)
#define LPW    (float)letters / (words ? words : 1)
#define SPW    (vowels * FACTOR) / (words ? words : 1)

int    bytes = 0, characters = 0, words = 0, lines = 0;
int    letters = 0, vowels = 0, sentences = 0;

char   buffer[BUFFSIZE];

main(argc,argv)
int    argc;
char   *argv[];
{
       FILE    *stream;
       int     namebuf[15];
       char    *name;
       int     numread;
       char    inword = FALSE;

       /* Get a file if one was not specified as an argument   */

       if (argc > 1)
               name = argv[1];
       else {
               printf("Enter file name: ");
               name = gets(namebuf);
       }

       /* Open file in binary mode     */

       if ((stream = fopen(name,"rb")) == NULL)
               return (1);

       /* Read file buffers, passing bytes read and inword status      */

       while ((numread = fread(buffer,1,BUFFSIZE,stream)) != 0)
               inword = countwords(inword,numread);

       /* Calculate and print the results      */

       printf("\n\n\t\tFile statistics\n\n");
       printf("\t\tBytes: %d \n",bytes);
       printf("\t\tCharacters: %d \n",characters);
       printf("\t\tLetters: %d \n",letters);
       printf("\t\tVowels: %d \n",vowels);
       printf("\t\tConsonants %d \n",letters - vowels);
       printf("\t\tWords: %d \n",words);
       printf("\t\tLines: %d \n",lines ? lines : 1);
       printf("\t\tSentences: %d \n",sentences);
       printf("\t\tWords per sentence: %-.1f \n",WPS);
       printf("\t\tLetters per word: %-.1f \n",LPW);
       printf("\t\tEstimated syllables per word: %-.1f \n",SPW);
       return (0);
}

/*
 *  Analyze the chars in one buffer.
 *
 *  Increment bytes.  For each char, increment characters,
 *  lines, and/or words if appropriate.  For each character,
 *  call analyze function.  (A character is defined as a
 *  printable ASCII code.)
 */

countwords(inword,numread)
char   inword;
int    numread;
{
       int     count;
       char    code;

       bytes += numread;
       for (count = 0; count <= numread; ++count) {
               code = buffer[count];
               if (code == '\n')
                       ++lines;
               if (!inword) {
                       if (code > ' ') {
                               analyze(code,inword);
                               inword = TRUE;
                               ++words;
                               ++characters;
                       }
               }
               else {
                       if (code <= ' ')
                               inword = FALSE;
                       else {
                               ++characters;
                               analyze(code,inword);
                       }
               }
       }
       return(inword);
}

/*
 *  Analyze a character.
 *
 *  Increment letters, vowels, and/or sentences
 *  if appropriate.
 */

analyze(code,inword)
char   code;
char   inword;
{
       if (isalpha(code)) {
               ++letters;
               if ((strchr("AEIOUaeiou",code)) || (strchr("Yy",code) && inword))
                       ++vowels;
       }
       else {
               if (strchr(".!?",code))
                       ++sentences;
       }
}

