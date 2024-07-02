/*
** fggif.c
**
** Simple GIF viewer using Flash Graphics from Zortech.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <conio.h>
#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fg.h>
#include <limits.h>

FILE          *infile;            /* Input file handle                   */
unsigned int  screenwidth;        /* The dimensions of the screen        */
unsigned int  screenheight;       /*   (not those of the image)          */
char          global;             /* Is there a global color map?        */
char          global_sort;        /* Non-zero if global table is sorted. */
int           global_bits;        /* Number of bits of global colors     */
unsigned char global_map[256 * 3];/* The global color map.               */
int           backclr;            /* Background color (if global is set).*/
int           colres;             /* Number of bits of color resolution. */
int           *interleavetable;
char          *file_name;

typedef struct pal_entry
{
  unsigned char red, green, blue;
  unsigned short red_sq, green_sq, blue_sq;
} pal_entry_t;

pal_entry_t  *sorted_gif_palette[256];  /* Colors in descending importance. */
pal_entry_t  gif_palette[256];          /* Max of 256 simultaneous colors.  */
int          num_gif_palette_colors;    /* Actual simultaneous colors.      */
fg_color_t   gif_to_fg_colortable[256]; /* Max of 256 simultaneous colors.  */

int          bad_code_count = 0;
fg_box_t     image_box;
fg_coord_t   image_width, image_height;
unsigned int row;

void  usage(void), bye_bye(void), fatal(const char *), check_signature(void);
void  read_extension(void);
void  read_screen(void), read_image(void);
void  init_colors(unsigned char *map, int ncolors, char sorted);
short decoder(short width);

/* Various error codes used by decoder
 * and my own routines...   It's okay
 * for you to define whatever you want,
 * as long as it's negative...  It will be
 * returned intact up the various subroutine
 * levels...
 */
#define OUT_OF_MEMORY -10
#define BAD_CODE_SIZE -20
#define READ_ERROR EOF
#define WRITE_ERROR -2
#define OPEN_ERROR -3
#define CREATE_ERROR -4

#define ESC 0x1b
#define arraysize(a) (sizeof(a)/sizeof((a)[0]))

#if 1
#define get_byte() fgetc(infile)
#else
/****************************************************************************
Used globally to read from the file/data stream.
March 13, 1991
****************************************************************************/
int get_byte(void)
{
  int ch = fgetc(infile);

  return ch == EOF? READ_ERROR: ch;
}
#endif


/*
** Main Program - open specified GIF file, read and verify GIF signature
**                load screen descriptor, global color map
**                        Z load image descriptor ?
**                Repeat -3 load local color map  3- for each image in file
**                        3 decode image          3
**                        @ skip extension blocks Y
**                Done - pause for keypress
*/

int main(int argc, char *argv[])
{
  int arg_num = 0;

  if(argc < 2)
    usage();

  while(++arg_num < argc)
  {
    char *name_p = 0;
    int  quit;
    char ch;

    file_name = argv[arg_num];

    if((infile = fopen(file_name,"rb")) == 0)
    {
      name_p = file_name = malloc(strlen(argv[arg_num]) + 1 + 4);

      if(!name_p)
        fatal("No memory.");

      strcat(strcpy(name_p, argv[arg_num]), ".gif");

      if((infile = fopen(name_p,"rb")) == 0)
      {
        perror(argv[0]);
        exit(-1);
      }
    }

    check_signature();
    read_screen();

    quit = 0;
    do
    {
      ch = get_byte();
      switch (ch)
      {
        case '\0':  break;  /* this kludge for non-standard files */
        case ',':   read_image();
                    break;
        case ';':   quit = 1;
                    break;
        case '!':   read_extension();
                    break;
        default:    break;
      }
      fg_flush();
    } while (!quit);

    fclose(infile);

    do
    {
      if(getch() == ESC)
        bye_bye();
    }while(kbhit());

    if(name_p)
      free(name_p);
  }
  bye_bye();
  return 0;/* Not reached but some compilers complain about no return value. */
}

void usage(void)
{
  fprintf(stderr,"usage: fggif [GIF-file]\n");
  exit(1);
}

void bye_bye(void)
{
  if(fg.display)
    fg_term();
  exit(0);
}

void fatal(const char *s)
{
  if(fg.display)
    fg_term();
  fprintf(stderr,"fggif: %s\n",s);
  exit(1);
}

void check_signature(void)
{
  char buf[6];

  fread(buf,sizeof(buf[0]),6,infile);
  if(strncmp(buf,"GIF",3))
    fatal("file is not a GIF file");

  if(strncmp(&buf[3],"87a",3))
    fatal("Only GIF 87a supported");
}

void read_screen()
{
  unsigned char buf[7];

  fread(buf,sizeof(buf[0]),7,infile);

  if (buf[6]) fatal("screen descriptor is invalid");

  screenwidth  = buf[0] + ((unsigned short)buf[1] << 8);
  screenheight = buf[2] + ((unsigned short)buf[3] << 8);
  global       = buf[4] & 0x80;
  colres       = ((buf[4] & 0x70) >> 4) + 1;
  global_bits  = (buf[4] & 0x07) + 1;
  global_sort  = (buf[4] & 0x08) != 0;
  backclr      = buf[5];

  if(global)
    fread((char *)global_map,1,3 * (1 << global_bits),infile);
}


static char fg_env[40] = "FG_DISPLAY";

/****************************************************************************
Compare the environment string to the static string in fg_init_all().
April 2, 1990
****************************************************************************/
static int env_cmp (const char *env_p, const char *str_p)
{
  if(strcmpl(env_p,str_p) &&
     strcmpl(env_p,str_p + 3) &&       /* ignore "FG_" */
     strcmpl(env_p + 1,str_p) &&       /* ignore leading " " on environment. */
     strcmpl(env_p + 1,str_p + 3))     /* ignore leading " " and FG_ */
  {
    return 1;
  }
  return 0;   /* Match found. */
}

/****************************************************************************
Set the search string for the environment.  Used to change from the default of
"FG_DISPLAY".  Maximum length is 39 characters (plus a terminating '\0').
August 1, 1989
****************************************************************************/
void _FAR fg_setenv_variable (const char _FAR * new_string)
{
  int length = 0;

  do
  {
    fg_env[length++] = *new_string;
  } while (*new_string++);
}

/****************************************************************************
Select and initialize the graphics mode appropriate for the image size and 
colors.  Return non-zero if successful.

FG should have a fg_get_first_mode(), fg_get_next_mode() that lets the
application query for best mode fit... someday but not today.

This overrides the fg_init_all() in the FG library allowing the reduction of
size of the executable by not pulling in certain drivers that are not useful.

  NOTE: At start up time the global "(*fg_init) ()" is pointing to this 
        function.  Calling fg_init will call this function on the first call 
        and which will reassign fg_init to the init for the proper display 
        graphics adapter.
  RETURNS:  Display type if successful.  FG_NULL if error occured.

March 13, 1991
****************************************************************************/
int _FAR fg_init_all (void)
{
  int i, ret_val;
  char *cptr;
  static struct
  {   char *string;           /* environment string           */
      int display;            /* FG_xxxxx                     */
      int (_FAR *init)(void);/* initialization function      */
  } types[] =
  {
      {   "FG_EGACOLOR",      FG_EGACOLOR,      fg_init_egacolor},
      {   "FG_EGAECD",        FG_EGAECD,        fg_init_egaecd},
      {   "FG_VGA12",         FG_VGA12,         fg_init_vga12},
#if !__OS2__
      {   "FG_EGALOWRES",     FG_EGALOWRES,     fg_init_egalowres},
      {   "FG_VGA13",         FG_VGA13,         fg_init_vga13},
      {   "FG_TIGA",          FG_TIGA,          fg_init_tiga},
#if !(M_UNIX || M_XENIX)
      {   "FG_ATI61",         FG_ATI61,         fg_init_ati61},
      {   "FG_ATI62",         FG_ATI62,         fg_init_ati62},
      {   "FG_ATI63",         FG_ATI63,         fg_init_ati63},
      {   "FG_EVGAHIRES",     FG_EVGAHIRES,     fg_init_evgahires},
      {   "FG_PARADISEHIRES", FG_PARADISEHIRES, fg_init_paradisehires},
      {   "FG_TRIDENTHIRES",  FG_TRIDENTHIRES,  fg_init_tridenthires},
      {   "FG_ORCHIDPROHIRES",FG_ORCHIDPROHIRES,fg_init_orchidprohires},
      {   "FG_DFIHIRES",      FG_DFIHIRES,      fg_init_dfihires},
      {   "FG_VEGAVGAHIRES",  FG_VEGAVGAHIRES,  fg_init_vegavgahires},
      {   "FG_VESA6A",        FG_VESA6A,        fg_init_vesa6A},
      {   "FG_VESA0",         FG_VESA0,         fg_init_vesa0},
      {   "FG_VESA1",         FG_VESA1,         fg_init_vesa1},
      {   "FG_VESA2",         FG_VESA2,         fg_init_vesa2},
      {   "FG_VESA3",         FG_VESA3,         fg_init_vesa3},
      {   "FG_VESA5",         FG_VESA5,         fg_init_vesa5},
      {   "FG_VESA7",         FG_VESA7,         fg_init_vesa7}
#endif
#endif  /* OS2 */
  };

  /* If environment variable FG_DISPLAY exists, use it to determine the  */
  /* display type             */
  cptr = getenv(fg_env);

  if(!cptr)
  {
    char *s1_p = fg_env, *s2_p, buf[sizeof(fg_env) + 1];

    s2_p = buf;         /* Add a trailing space on the end of the */
    while(*s1_p)        /* environment variable.                  */
      *s2_p++ = *s1_p++;

    *s2_p++ = ' ';
    *s2_p = 0;

    cptr = getenv(buf);
  }

  /* If already initialized and resolution is okay don't reinitialize. */
  if(fg.display)
  {
    if(image_width  == fg_box_width(fg.displaybox) &&
       image_height == fg_box_height(fg.displaybox))
    {
      ret_val = fg.display;
      goto init_palette;
    }
    else
      fg_term();
  }

  if (cptr)
  {
    for (i = 0; i < arraysize(types); i++)
    {
      if(!env_cmp(cptr,types[i].string)) /* If strings match */
      {
        ret_val = (*(types[i].init))();
        goto init_palette;
      }
    }
    return FG_NULL;   /* display not available  */
  }
  else          /* no FG_DISPLAY environment variable */
  {
    ret_val = fg_get_type();   /* Try to figure it out. */

    switch(ret_val)
    {
    case FG_TIGA:
      break;

    case FG_EGALOWRES:     /* EGA in 320 x 200 x 16 colors (mode 0x0D)     */
    case FG_EGACOLOR:      /* EGA with regular color display (mode 0x0E)   */
    case FG_EGAECD:        /* EGA with enhanced color display (mode 0x10)  */
      if(screenwidth <= 320 && screenheight <= 200)
      {
        ret_val = fg_init_egalowres();
        goto init_palette;
      }
      break;

    case FG_VGA12:         /* IBM VGA in 640*480, 16 colors              */
    case FG_VGA13:         /* IBM VGA in 320*200, 256 colors             */
    case FG_ORCHIDPROHIRES:/* ORCHID PRO DESIGNER VGA 800*600, 16 colors */
    case FG_PARADISEHIRES: /* PARADISE VGA 800*600, 16 colors            */
    case FG_TRIDENTHIRES:  /* TRIDENT VGA 800*600, 16 colors             */
    case FG_VEGAVGAHIRES:  /* VIDEO 7 VEGA VGA in 800 x 600, 16 colors   */
    case FG_DFIHIRES:      /* Diamond Flower Instruments 800 x 600 x 16  */
    case FG_VESA6A:        /* VESA mode 0x6A, 800 x 600, 16 colors.      */
    case FG_EVGAHIRES:     /* Everex EVGA in 800 x 600, 16 colors        */
    case FG_VESA2:         /* VESA mode 0x102, 800 x 600, 16 colors.     */
      if(screenwidth <= 320 && screenheight <= 200)
      {
        ret_val = FG_VGA13;
      } else
      if(screenwidth <= 640 && screenheight <= 480)
      {
        ret_val = FG_VGA12;
      }
      break;

    default:
      return FG_NULL;
    }
  }

  if(ret_val != FG_NULL)
  {
    /* Call initialization function corresponding to display type */
    for (i = 0; i < arraysize(types); i++)
    {
      if (types[i].display == ret_val)
      {
          ret_val = (*(types[i].init))();
          break;
      }
    }
  }

init_palette:
  if(ret_val)
  {
    fg_setcolornum(FG_LIGHT_WHITE,1);   /* Suggested by GIF documents. */
    fg_setpalette(1,~0,~0,~0);

    fg_setcolornum(FG_BLACK,0);
    fg_setpalette(0,0,0,0);
  }
  return ret_val;
}

/****************************************************************************
Set up the hardware for proper color redition.
March 13, 1991
****************************************************************************/
static void load_palette(void)
{
  pal_entry_t *p;
  int i = fg.nsimulcolor;

  if(i > num_gif_palette_colors)
    i = num_gif_palette_colors;

  do
  {
    p = sorted_gif_palette[--i];
    fg_setpalette(i, p->red, p->green, p->blue);
  } while (i > 0);
}


/****************************************************************************
Return the distance between two palette entries.
March 13, 1991
****************************************************************************/
static unsigned long palette_delta(const pal_entry_t *p1, const pal_entry_t *p2)
{
  long red, green, blue;

  red = p1->red;
  red -= p2->red;

  green = p1->green;
  green -= p2->green;

  blue = p1->blue;
  blue -= p2->blue;

  return red * red + green * green + blue * blue;
}

/****************************************************************************
Below and include 'divider' in sorted_gif_palette[] is the list of palette 
entries that are maximally far apart.  Above 'divider' up to 
num_gif_palette_colors is a list of entries from which one entry should be
selected that is farthest away from all the entries below 'divider'.

March 13, 1991
****************************************************************************/
static int find_farthest_palette_entry(int divider)
{
  int ret_val = divider + 1, i_lower, i_upper;
  unsigned long min_metric = ULONG_MAX;

  for(i_upper = divider + 1; i_upper < num_gif_palette_colors; i_upper++)
  {
    unsigned long metric = ULONG_MAX;
    pal_entry_t *p = sorted_gif_palette[i_upper];

    for (i_lower = 0; i_lower <= divider; i_lower++)
    {
      unsigned long temp = palette_delta(p, sorted_gif_palette[i_lower]);
      if(temp == 0)
      {
        metric = ULONG_MAX;
        break;
      }
      else
        metric += (ULONG_MAX/256)/temp;
    }

    if(metric < min_metric)
    {
      ret_val = i_upper;
      min_metric = metric;
    }
  }
  return ret_val;
}

/****************************************************************************
Find the closest entry to *p in the sorted gif palette prior to this index.
March 13, 1991
****************************************************************************/
static int find_closest_fg(const pal_entry_t *p, int max_index)
{
  unsigned long min_distance = ULONG_MAX;
  int ret_val, i = max_index - 1;

  do
  {
    unsigned long distance = palette_delta(p, sorted_gif_palette[i]);

    if(distance < min_distance)
    {
      min_distance = distance;
      ret_val = i;
    }
  } while(--i >= 0);

  return ret_val;
}

/****************************************************************************
Sort the gif palette according to the colors that are the greatest distance
apart from each other.  This isn't optimum (optimum would require relative
frequency of each color) but should create a mapping that is better than 
random.

If I were to define optimum it would be as follows:

Sum of pal_delta for each pixel kept to a minimum.

pal_delta equals:
  (fg_red - gif_red)^2 + (fg_green - gif_green)^2 + (fg_blue - gif_blue)^2

A crude outline of how create the optimum (using this metric) would be to go 
through the image and kept a count of how many occurances of a particular 
palette entry occured.  Then the metric could be easily computed as:

  metric_val = 0;
  for(i = 0; i < num_gif_palette_colors; i++)
    metric_val += pal_freq[i] * pal_delta[i];

Then the tough part comes.  Changing the values of fg_red, fg_green, fg_blue
such that the metric is minimized.  A first approximation could be to take
the most frequently occuring palette entrys (largest entries in pal_freq[])
and chose fg_red, fg_green, and fg_blue such that those deltas are minimized.
This won't always work of course...

March 13, 1991
****************************************************************************/
static void sort_palette(void)
{
  if(num_gif_palette_colors > fg.nsimulcolor)
  {
    pal_entry_t pal;
    int done_index, i;

    memset(&pal,0,sizeof(pal));  /* An entry of BLACK -- a starting point. */

    i = find_closest_fg(&pal, num_gif_palette_colors);
    done_index = 0;

    do
    {
      pal_entry_t *pal_p;

      pal_p = sorted_gif_palette[done_index];
      sorted_gif_palette[done_index] = sorted_gif_palette[i];
      sorted_gif_palette[i] = pal_p;

      i = find_farthest_palette_entry(done_index);
    } while (++done_index < fg.nsimulcolor);
  }
}

/****************************************************************************
Map all the GIF color numbers into a FG color number.  Put FG color number
in gif_to_fg_colortable[] at index 'gif_color_number'.  sorted_gif_palette[] 
must already be sorted according to decreasing importance.  FG must be 
initialized.
March 13, 1991
****************************************************************************/
static void map_palette(void)
{
  int i;

  for(i = 0; i < fg.nsimulcolor; i++)
  {
    gif_to_fg_colortable[i] = i;
  }

  while(i < num_gif_palette_colors)
  {
    gif_to_fg_colortable[i] =
      find_closest_fg(sorted_gif_palette[i], fg.nsimulcolor);
    i++;
  }
}

/****************************************************************************
Sort the color palette (if necessary).  This is to decide which colors to use.
Create the table that maps the GIF palette into the available FG palette.
March 13, 1991
****************************************************************************/
static void init_colors(unsigned char *map, int ncolors, char sorted)
{
  pal_entry_t **sort_p = &sorted_gif_palette[0];
  pal_entry_t *p = &gif_palette[0];

  num_gif_palette_colors = ncolors;

  do
  {
    *sort_p++ = p;
    p->red = *map++;    p->green = *map++;    p->blue = *map++;
    p++;
  } while (--ncolors > 0);

  if(!sorted)
    sort_palette();
  map_palette();
}


int out_line(unsigned char *line, int len)
{
  if(interleavetable[row] <= fg.displaybox[FG_Y2])
  {
    fg_color_t *p = (fg_color_t *) line;
    fg_box_t b;
    fg_coord_t y = interleavetable[row];
    fg_coord_t x, xmax;

    len--;
    xmax = len < fg.displaybox[FG_X2]? len: fg.displaybox[FG_X2];

    fg_make_box(b,0,y,xmax,y);

    for(x = 0; x <= xmax; x++, line++)
      *line = gif_to_fg_colortable[*line];

    fg_writebox(b,p);
  }

  row++;
  return 0;
}


static void read_image(void)
{
  int           color_bits;
  char          mess_buf[80];
  char          local,interleaved,sorted;
  unsigned char buf[9], localmap[256 * 3], *map_p;
  fg_coord_t    line_spacing;
  fg_coord_t    mess_y;
  fg_coord_t    ymax;

  fread(buf,sizeof(buf[0]),9,infile);

  image_height = (buf[2] + (((fg_coord_t)buf[3]) << 8));
  image_box[FG_X1] = buf[0] + (((fg_coord_t)buf[1]) << 8);

  image_width  = buf[4] + (((fg_coord_t)buf[5]) << 8);
  image_box[FG_X2] = image_width - 1;

  interleaved = (buf[8] & 0x40) != 0;
  sorted = (buf[8] & 0x20) != 0;

  if(!fg_init_all())  /* Very special version of fg_init_all(). */
    fatal("Unable to open graphics device.");

  line_spacing = fg_box_height(fg.charbox) + 2;
  mess_y = fg.displaybox[FG_Y2] - line_spacing;

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,
    "Uses Zortech C and Flash Graphics",fg.displaybox);
  mess_y -= 2 * line_spacing;

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,
    "The Graphics Interchange Format(c) is",fg.displaybox);
  mess_y -= line_spacing;

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,
    "the Copyright property of CompuServe",fg.displaybox);
  mess_y -= line_spacing;

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,
    "Incorporated.  GIF(sm) is a Service Mark",fg.displaybox);
  mess_y -= line_spacing;

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,
    "property of CompuServe Incorporated.",fg.displaybox);
  mess_y -= 2 * line_spacing;

  image_box[FG_Y2] = fg.displaybox[FG_Y2] - image_height - 1;
  image_box[FG_Y1] = fg.displaybox[FG_Y2] - (buf[6] +
                     (((fg_coord_t)buf[7]) << 8));

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,file_name,fg.displaybox);
  mess_y -= line_spacing;

  sprintf(mess_buf, "GIF87a %d x %d %sbitmap",
    fg_box_width(image_box),fg_box_height(image_box),
    (interleaved ? "interleaved ":""));
  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,mess_buf,fg.displaybox);
  mess_y -= line_spacing;

  sprintf(mess_buf, "Screen mode: 0x%x -- %d x %d x %d", fg.display,
    fg_box_width(fg.displaybox),fg_box_height(fg.displaybox),fg.nsimulcolor);
  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,mess_buf,fg.displaybox);
  mess_y -= line_spacing;

  if (global)
  {
    sprintf(mess_buf,"Global Map: %d bit color.",  global_bits);
    fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,mess_buf,
      fg.displaybox);
    mess_y -= line_spacing;

    sprintf(mess_buf,"%d bits per color digitization.", colres);
    fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,mess_buf,
      fg.displaybox);
    mess_y -= line_spacing;
  }

  local = buf[8] & 0x80;
  if(local)
  {
      int localbits = (buf[8] & 0x7) + 1;
      color_bits = localbits;
      sprintf(mess_buf,"Local Map: %d bit color", localbits);
      fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,mess_buf,fg.displaybox);
      mess_y -= line_spacing;

      fread(localmap, 1, 3 * (1 << localbits),infile);
      map_p = localmap;
  } else
  if(global)
  {
      map_p = global_map;
      color_bits = global_bits;
      sorted = global_sort;
  } else
      fatal("no colormap present for image");

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,
    "Sorting color map...",fg.displaybox);
  mess_y -= line_spacing;
  fg_flush();

  init_colors(map_p, 1 << color_bits, sorted);

  fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,mess_y,
    "Press any key to continue...",fg.displaybox);
  fg_flush();

  do
  {
    if(getch() == ESC)
      bye_bye();
  }while(kbhit());

  /* Clear the screen. */
  fg_fillbox(global? gif_to_fg_colortable[backclr]: FG_BLACK, FG_MODE_SET, ~0,
    fg.displaybox);
  load_palette();  /* Changes color definitions. */

  interleavetable = (int*)malloc(
    fg_box_height(image_box) * sizeof(int));
  if (!interleavetable)
     fatal("not enough memory for interleave table");

  ymax = fg_box_height(image_box) - 1;
  if(interleaved)
  {
    fg_coord_t y;

    row = 0;

    for (y = 0; y <= ymax; y += 8)
      interleavetable[row++] = ymax - y;

    for (y = 4; y <= ymax; y += 8)
      interleavetable[row++] = ymax - y;

    for (y = 2; y <= ymax; y += 4)
      interleavetable[row++] = ymax - y;

    for (y = 1; y <= ymax; y += 2)
      interleavetable[row++] = ymax - y;
  }
  else
  {
    fg_coord_t y;

    for (y = 0; y <= ymax; y++)
      interleavetable[y] = ymax - y;
  }

  row = 0;
  switch(decoder(fg_box_width(image_box)))
  {
     case(OUT_OF_MEMORY): fatal("Out of memory");
                          break;
     case(BAD_CODE_SIZE): fatal("Bad Code Size");
                          break;
     case(READ_ERROR):    fatal("Read Error");
                          break;
     case(WRITE_ERROR):   fatal("Write Error");
                          break;
     case(OPEN_ERROR):    fatal("Open Error");
                          break;
     case(CREATE_ERROR):  fatal("Create Error");
                          break;
  }

  if(interleaved)
    free(interleavetable);
}


void read_extension()
{
  unsigned char code,count;
  char buf[255];

  code = get_byte();
  while ((count = get_byte()) != 0) 
    fread(buf,sizeof(buf[0]),count,infile);
}
/*************************
Remaining code is copyright by Steven A. Bennett
I have made numerous changes however it is still fundamentally his code.
*************************/

/* DECODE.C - An LZW decoder for GIF
 * Copyright (C) 1987, by Steven A. Bennett
 *
 * Permission is given by the author to freely redistribute and include
 * this code in any program as long as this credit is given where due.
 *
 * In accordance with the above, I want to credit Steve Wilhite who wrote
 * the code which this is heavily inspired by...
 *
 * GIF and 'Graphics Interchange Format' are trademarks (tm) of
 * Compuserve, Incorporated, an H&R Block Company.
 *
 * Release Notes: This file contains a decoder routine for GIF images
 * which is similar, structurally, to the original routine by Steve Wilhite.
 * It is, however, somewhat noticably faster in most cases.
 *
 */

/* extern int get_byte()
 *
 *   - This external (machine specific) function is expected to return
 * either the next byte from the GIF file, or a negative number, as
 * defined in ERRS.H.
 */

/* extern int out_line(unsigned char *pixels, int linelen)
 *
 *   - This function takes a full line of pixels (one byte per pixel) and
 * displays them (or does whatever your program wants with them...).  It
 * should return zero, or negative if an error or some other event occurs
 * which would require aborting the decode process...  Note that the length
 * passed will almost always be equal to the line length passed to the
 * decoder function, with the sole exception occurring when an ending code
 * occurs in an odd place in the GIF file...  In any case, linelen will be
 * equal to the number of pixels passed...
 */
extern int out_line(unsigned char *pixels, int linelen);

/* extern int bad_code_count;
 *
 * This value is the only other global required by the using program, and
 * is incremented each time an out of range code is read by the decoder.
 * When this value is non-zero after a decode, your GIF file is probably
 * corrupt in some way...
 */
extern int bad_code_count;

#define MAX_CODES   4095

/* Static variables */
static short curr_size;                     /* The current code size */
static short clear;                         /* Value for a clear code */
static short ending;                        /* Value for a ending code */
static short newcodes;                      /* First available code */
static short top_slot;                      /* Highest code for current size */
static short slot;                          /* Last read code */

/* The following static variables are used
 * for seperating out codes
 */
static short navail_bytes = 0;         /* # bytes left in block */
static short nbits_left = 0;           /* # bits left in current byte */
static unsigned char b1;              /* Current byte */
static unsigned char byte_buff[257];  /* Current block */
static unsigned char *pbytes;         /* Pointer to next byte in block */

static long code_mask[13] = {
     0,
     0x0001, 0x0003,
     0x0007, 0x000F,
     0x001F, 0x003F,
     0x007F, 0x00FF,
     0x01FF, 0x03FF,
     0x07FF, 0x0FFF
     };


/* This function initializes the decoder for reading a new image.
 */
static short init_exp(short size)
{
   curr_size = size + 1;
   top_slot = 1 << curr_size;
   clear = 1 << size;
   ending = clear + 1;
   slot = newcodes = ending + 1;
   navail_bytes = nbits_left = 0;
   return(0);
}

/* get_next_code()
 * - gets the next code from the GIF file.  Returns the code, or else
 * a negative number in case of file errors...
 */
static short get_next_code(void)
{
   short i, x;
   unsigned long ret;

   if (nbits_left == 0)
   {
      if (navail_bytes <= 0)
      {

         /* Out of bytes in current block, so read next block
          */
         pbytes = byte_buff;
         if ((navail_bytes = get_byte()) < 0)
            return(navail_bytes);
         else if (navail_bytes)
         {
            for (i = 0; i < navail_bytes; ++i)
            {
               if ((x = get_byte()) < 0)
                  return(x);
               byte_buff[i] = x;
            }
         }
      }
      b1 = *pbytes++;
      nbits_left = 8;
      --navail_bytes;
   }

   ret = b1 >> (8 - nbits_left);
   while (curr_size > nbits_left)
   {
      if (navail_bytes <= 0)
      {
         /* Out of bytes in current block, so read next block
          */
         pbytes = byte_buff;
         if ((navail_bytes = get_byte()) < 0)
            return(navail_bytes);
         else if (navail_bytes)
         {
            for (i = 0; i < navail_bytes; ++i)
            {
               if ((x = get_byte()) < 0)
                  return(x);
               byte_buff[i] = x;
            }
         }
      }
      b1 = *pbytes++;
      ret |= b1 << nbits_left;
      nbits_left += 8;
      --navail_bytes;
   }
   nbits_left -= curr_size;
   ret &= code_mask[curr_size];
   return((short)(ret));
}


/* The reason we have these seperated like this instead of using
 * a structure like the original Wilhite code did, is because this
 * stuff generally produces significantly faster code when compiled...
 * This code is full of similar speedups...  (For a good book on writing
 * C for speed or for space optomisation, see Efficient C by Tom Plum,
 * published by Plum-Hall Associates...)
 */
static unsigned char stack[MAX_CODES + 1];    /* Stack for storing pixels */
static unsigned char suffix[MAX_CODES + 1];   /* Suffix table */
static unsigned short prefix[MAX_CODES + 1];  /* Prefix linked list */

/* short decoder(linewidth)
 *    short linewidth;               * Pixels per line of image *
 *
 * - This function decodes an LZW image, according to the method used
 * in the GIF spec.  Every *linewidth* "characters" (ie. pixels) decoded
 * will generate a call to out_line(), which is a user specific function
 * to display a line of pixels.  The function gets it's codes from
 * get_next_code() which is responsible for reading blocks of data and
 * seperating them into the proper size codes.  Finally, get_byte() is
 * the global routine to read the next byte from the GIF file.
 *
 * It is generally a good idea to have linewidth correspond to the actual
 * width of a line (as specified in the Image header) to make your own
 * code a bit simpler, but it isn't absolutely necessary.
 *
 * Returns: 0 if successful, else negative.
 *
 */

short decoder(short linewidth)
{
   unsigned char *sp, *bufptr;
   unsigned char *buf;
   short code, fc, oc, bufcnt;
   short c, size, ret;

   /* Initialize for decoding a new image...
    */
   if ((size = get_byte()) < 0)
      return(size);
   if (size < 2 || 9 < size)
      return(BAD_CODE_SIZE);
   init_exp(size);

   /* Initialize in case they forgot to put in a clear code.
    * (This shouldn't happen, but we'll try and decode it anyway...)
    */
   oc = fc = 0;

   /* Allocate space for the decode buffer
    */

   buf = (unsigned char *)malloc(linewidth + 1);
   if(!buf)
      return(OUT_OF_MEMORY);

   /* Set up the stack pointer and decode buffer pointer
    */
   sp = stack;
   bufptr = buf;
   bufcnt = linewidth;

   /* This is the main loop.  For each code we get we pass through the
    * linked list of prefix codes, pushing the corresponding "character" for
    * each code onto the stack.  When the list reaches a single "character"
    * we push that on the stack too, and then start unstacking each
    * character for output in the correct order.  Special handling is
    * included for the clear code, and the whole thing ends when we get
    * an ending code.
    */
   while ((c = get_next_code()) != ending)
   {
      /* If we had a file error, return without completing the decode
       */
      if (c < 0)
      {
        free(buf);
        return(0);
      }

      /* If the code is a clear code, reinitialize all necessary items.
       */
      if (c == clear)
      {
         curr_size = size + 1;
         slot = newcodes;
         top_slot = 1 << curr_size;

         /* Continue reading codes until we get a non-clear code
          * (Another unlikely, but possible case...)
          */
         while ((c = get_next_code()) == clear)
            ;

         /* If we get an ending code immediately after a clear code
          * (Yet another unlikely case), then break out of the loop.
          */
         if (c == ending)
            break;

         /* Finally, if the code is beyond the range of already set codes,
          * (This one had better NOT happen...  I have no idea what will
          * result from this, but I doubt it will look good...) then set it
          * to color zero.
          */
         if (c >= slot)
            c = 0;

         oc = fc = c;

         /* And let us not forget to put the char into the buffer... And
          * if, on the off chance, we were exactly one pixel from the end
          * of the line, we have to send the buffer to the out_line()
          * routine...
          */
         *bufptr++ = c;
         if (--bufcnt == 0)
         {
            if ((ret = out_line(buf, linewidth)) < 0)
            {
               free(buf);
               return(ret);
            }
            bufptr = buf;
            bufcnt = linewidth;
         }
      }
      else
      {
         /* In this case, it's not a clear code or an ending code, so
          * it must be a code code...  So we can now decode the code into
          * a stack of character codes. (Clear as mud, right?)
          */
         code = c;

         /* Here we go again with one of those off chances...  If, on the
          * off chance, the code we got is beyond the range of those already
          * set up (Another thing which had better NOT happen...) we trick
          * the decoder into thinking it actually got the last code read.
          * (Hmmn... I'm not sure why this works...  But it does...)
          */
         if (code >= slot)
         {
            if (code > slot)
               ++bad_code_count;
            code = oc;
            *sp++ = fc;
         }

         /* Here we scan back along the linked list of prefixes, pushing
          * helpless characters (ie. suffixes) onto the stack as we do so.
          */
         while (code >= newcodes)
         {
            *sp++ = suffix[code];
            code = prefix[code];
         }

         /* Push the last character on the stack, and set up the new
          * prefix and suffix, and if the required slot number is greater
          * than that allowed by the current bit size, increase the bit
          * size.  (NOTE - If we are all full, we *don't* save the new
          * suffix and prefix...  I'm not certain if this is correct...
          * it might be more proper to overwrite the last code...
          */
         *sp++ = code;
         if (slot < top_slot)
         {
            suffix[slot] = fc = code;
            prefix[slot++] = oc;
            oc = c;
         }
         if (slot >= top_slot)
         {
            if (curr_size < 12)
            {
               top_slot <<= 1;
               ++curr_size;
            }
         }
         /* Now that we've pushed the decoded string (in reverse order)
          * onto the stack, lets pop it off and put it into our decode
          * buffer...  And when the decode buffer is full, write another
          * line...
          */
         while (sp > stack)
         {
            *bufptr++ = *(--sp);
            if (--bufcnt == 0)
            {
               if ((ret = out_line(buf, linewidth)) < 0)
               {
                  free(buf);
                  return(ret);
               }
               bufptr = buf;
               bufcnt = linewidth;
            }
         }
      }
   }
   ret = 0;
   if (bufcnt != linewidth)
      ret = out_line(buf, (linewidth - bufcnt));
   free(buf);
   return(ret);
}
