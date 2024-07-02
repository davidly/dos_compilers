/*_ iconed.c Tue Jan 13 1987 Modified by: Walter Bright */
/* Written by Walter Bright                             */
/* Icon editor                                          */
/* Modified by Joe Huffman September 18, 1990           */

/* Copyright Prototronics */
/* 6490 Kaniksu Shores Circle */
/* Sandpoint, ID  83864-9445 */
/* Joe Huffman */
/* September 6, 1990 */
/* Voice: 208-263-1695 */
/* FAX:   208-263-8772 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <fg.h>

#define XTEND(a) (a<<8)   /* For encoding an extended key code into an int. */
#define ESC (0x1b)
#define UPARROW XTEND(72)
#define LARROW XTEND(75)
#define RARROW XTEND(77)
#define DNARROW XTEND(80)

#define ROWS    30
#define COLS    120
unsigned char icon[COLS][ROWS];

void icon_setbit(int r, int c, int val);
void icon_read(char *filename);
void icon_write(char *filename);
void usage(void);

int main(int argc, char *argv[])
{
  fg_line_t line;
  fg_coord_t x,y;
  int char_to_do;
  int row,col;
  fg_color_t color;
  int mode = FG_MODE_SET;
  int mask = ~0;
  char drawing = 0;
  char erasing = 0;
  char done = 0;

  if(argc < 2 || !fg_init() || !fg.msm)
    usage();

  color = FG_WHITE;

  fg_make_line(line,0,0,COLS * 5,0);
  for (row = 0; row <= ROWS; row++)
  {       line[FG_Y1] = line[FG_Y2] = row * 5;
          fg_drawline(color,mode,mask,FG_LINE_SOLID,line);
  }
  fg_make_line(line,0,0,0,ROWS * 5);
  for (col = 0; col <= COLS; col++)
  {       line[FG_X1] = line[FG_X2] = col * 5;
          fg_drawline(color,mode,mask,FG_LINE_SOLID,line);
  }

  if(argc > 1)
  {
    icon_read(argv[1]);

    if((char_to_do = atoi(argv[1])) != 0 && char_to_do < 256)
    {
      fg_box_t b;

      fg_putc(FG_LIGHT_WHITE, mode, mask, FG_ROT0, 1, 20 + ROWS * 5, 
        char_to_do, fg.displaybox);

      fg_box_cpy(b, fg.charbox);
      b[FG_Y1] += 20 + ROWS * 5 - 1;
      b[FG_Y2] += 20 + ROWS * 5 + 1;
      b[FG_X2] += 2;
      fg_drawbox(color, mode, mask, FG_LINE_SOLID, b, fg.displaybox);
    }
  }

  fg_msm_showcursor();

  do
  {
      int status;

      fg_flush();

      while((status = fg_msm_getstatus(&x, &y)) != 0)
      {
          if (y < ROWS * 5 && x < COLS * 5)
          {   row = y / 5;
              col = x / 5;
              if (drawing && icon[col][row] == 0)
                      icon_setbit(row,col,1);
              else if (erasing && icon[col][row] == 1)
                      icon_setbit(row,col,0);
          }
          fg_flush();
          if(status & FG_MSM_LEFT)
              drawing = 1;
          else
              drawing = 0;

          if(status & FG_MSM_RIGHT)
              erasing = 1;
          else
              erasing = 0;
      }

      if(kbhit())
      {
          int cc = getch();

          if(cc == 0)
            cc = XTEND(getch());

          switch(cc)
          {
          case RARROW:
              for (row = 0; row < ROWS; row++)
              {   for (col = COLS; --col;)
                          icon_setbit(row,col,icon[col - 1][row]);
                  icon_setbit(row,col,0);
              }
              break;
          case LARROW:
              for (row = 0; row < ROWS; row++)
              {   for (col = 0; col < COLS - 1; col++)
                          icon_setbit(row,col,icon[col + 1][row]);
                  icon_setbit(row,col,0);
              }
              break;
          case UPARROW:
              for (col = 0; col < COLS; col++)
              {   for (row = ROWS; --row;)
                          icon_setbit(row,col,icon[col][row - 1]);
                  icon_setbit(row,col,0);
              }
              break;
          case DNARROW:
              for (col = 0; col < COLS; col++)
              {   for (row = 0; row < ROWS - 1; row++)
                          icon_setbit(row,col,icon[col][row + 1]);
                  icon_setbit(row,col,0);
              }
              break;
          case 'I':
          case 'i':
              for (row = 0; row < ROWS; row++)
                  for (col = 0; col < COLS; col++)
                          icon_setbit(row,col,!icon[col][row]);
              break;
          case ESC:
          case 'Q':
          case 'q':
              done = 1;
              break;

          case 'C':
          case 'c':
          case 'E':
          case 'e':
              for (row = 0; row < ROWS; row++)
                  for (col = 0; col < COLS; col++)
                          icon_setbit(row,col,0);
              break;
          default:
              break;
          }
      }
  } while(!done);

  fg_term();

  if (argc > 1)
    icon_write(argv[1]);
  return 0;
}

void usage(void)
{
  fg_term();
  fputs(
"This program requires a mouse with a Microsoft compatible driver\n\
and a CGA, EGA, VGA, or Hercules compatible graphics adapter.\n\n\
usage: iconed filename\n\
 or    iconed number\n\n\
Where 'number' is a decimal number between 0 and 255 inclusive.  The\n\
filename/number is the source and destination file of the resultant\n\
icon being edited.  If a number is used the character associated\n\
with number for the default font is displayed beside your icon.\n\n\
Mouse button usage:\n\
Left button  - Set pixel.\n\
Right button - Clear pixel.\n\n\
Valid keyboard commands are:\n\
Right Arrow  - Move the icon one pixel right.\n\
Left Arrow   - Move the icon one pixel left.\n\
Down Arrow   - Move the icon one pixel down.\n\
Up Arrow     - Move the icon one pixel up.\n\
ESC or Q     - Exit saving the icon.\n\
C or E       - Clear (erase) the icon.\n\
Control C    - Exit without saving the icon.\n\
I            - Invert the icon color.", stdout);

  exit(1);
}

void icon_write(char *file)
{      int row,row1,row2,col,col1,col2;
       unsigned char rowbuf[(COLS + 7) / 8];
       int rowbufi,rowbufmax;
       FILE *f;

       f = fopen(file,"w");
       if (!f)
       {       perror(file);
               exit(1);
       }
       row1 = ROWS;
       row2 = -1;
       col1 = COLS;
       col2 = -1;
       for (row = 0; row < ROWS; row++)
               for (col = 0; col < COLS; col++)
               {   if (icon[col][row])
                   {   if (col > col2) col2 = col;
                       if (col < col1) { col1 = col; col = col2; }
                       if (row > row2) row2 = row;
                       if (row < row1) row1 = row;
                   }
               }
       fprintf(f,"fg_box_t icon_box_%s = {0,0,%d,%d};\n", file,
         col2 - col1,row2 - row1);
       rowbufmax = ((col2 - col1) + 8) / 8;
       fprintf(f,"char icon_matrix_%s [%d] =\n{\n", file,
         (row2 - row1 + 1) * rowbufmax);

       for (row = row2; row >= row1; row--)
       {   int bit;

           memset(rowbuf,0,rowbufmax);
           bit = 0;
           rowbufi = 0;
           for (col = col1; col <= col2; col++)
           {   if (bit == 8)
               {       bit = 0;
                       rowbufi++;
               }
               if (icon[col][row])
                       rowbuf[rowbufi] |= 0x80 >> bit;
               bit++;
           }
           for (rowbufi = 0; rowbufi < rowbufmax; rowbufi++)
           {
               fprintf(f,"0x%02x,",rowbuf[rowbufi]);
           }
           fprintf(f,"\t/* ");
           for (col = col1; col <= col2; col++)
               fputc((icon[col][row] ? 'X' : ' '),f);
           fprintf(f," */\n");
       }
       fprintf(f,"};\n");
       fclose(f);
}

void icon_read(char *file)
{
  char buff[COLS * 2 + 10];
  int row;

  FILE *f = fopen(file, "r");
  if(!f)
    return;

  row = ROWS - 1;

  while(fgets(buff, sizeof(buff), f))
  {
    if(buff[0] == '0')  /* Look for 0x.. lines. */
    {
      int col;
      char *c_p = buff;

      col = 0;
      do
      {
        int bit = 8;
        unsigned int b = (unsigned int)strtol(c_p,&c_p,16);  /* Use base 16. */

        if(b)
        {
          do
          {
            icon_setbit(row, col++, (b & (1 << --bit)) != 0);
          } while(bit);
        }
        else
          col += 8;
      } while (*(++c_p) == '0');  /* While more columns left. */
      row--;
    }
  }

  fclose(f);
}

void icon_setbit(int row, int col, int newval)
{   int mode = FG_MODE_SET;
    int mask = ~0;
    fg_color_t color;

    if (icon[col][row] != newval)
    {   fg_box_t box;

        icon[col][row] = newval;
        fg_make_box(box,col * 5 + 1,row * 5 + 1, col * 5 + 4,row * 5 + 4);
        color = newval ? FG_WHITE : FG_BLACK;
        fg_fillbox(color,mode,mask,box);
        fg_drawdot(color,mode,mask, 20 + col, ROWS * 5 + 20 + row);
    }
}
