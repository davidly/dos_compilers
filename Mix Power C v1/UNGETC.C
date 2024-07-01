/* ungetc and ungetch - reverse getc, getch */
/*   Copyright (c) Mix Software 1988    */

/* Replace character in buffer.  Will always work for at least
   one character.  For buffered files, ungetc can be called
   mulitiple times until the beginning of the buffer is reached.
   Returns EOF if unable to save character.
   */
ungetc(c,fp)
int c;
FILE *fp;
{
    if (c != EOF) {
        fp->file.eofflag = 0;
        if (fp->file.bufr) {
            if (fp->file.bufr == fp->file.ptr) {
                if (fp->file.count == 0) {
                    *fp->file.ptr = c;
                    fp->file.count = 1;
                    }
                else return EOF;
                }
            else {
                *(--fp->file.ptr) = c;
                ++fp->file.count;
                }
            }
        else {
            fp->file.ptr = &fp->file.ungetch;
            *fp->file.ptr = c;
            fp->file.count = 1;
            }
        }
   return c;
}

/* ------------------------------------------------------------ */
/* Reverse action of getch (unbuffered input from keyboard).
   Only one character can be saved; returns EOF if unable to
   save the character.
   */
ungetch(c)
int c;
{
    extern char _ungetch;
    if (_ungetch != EOF) return EOF;
    _ungetch = c;
    return c;
}

int     _ungetch = EOF;
