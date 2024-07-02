#include <graphics.h>
#include <malloc.h>

/* Create fill data patterns based on the number of available colors */
/* The first set of patterns are each of the available solid colors */
/* After the solid colors have been used, each pattern is used and  */
/* the color is changed for each pattern.  When the patterns are all */
/* used, they are repeated with a different starting color. */

struct fill_pattern *patterns(struct vconfig *screen_data, int sections)
{
#define PATS 22
   /*  Templates for the patterns */
   static char fill1[] = { 1, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0};
   static char fill2[] = { 0, 1, 0 };
   static char fill3[] = { 1, 0, 0, 0, 0,
                           0, 1, 0, 0, 0,
                           0, 0, 1, 0, 0,
                           0, 0, 0, 1, 0,
                           0, 0, 0, 0, 1};
   static char fill4[] = { 1, 1, 1,
                           0, 1, 0,
                           0, 1, 0};
   static char fill5[] = { 0, 0, 0, 0, 0,
                           0, 1, 1, 1, 0,
                           0, 1, 0, 1, 0,
                           0, 1, 1, 1, 0,
                           0, 0, 0, 0, 0};
   static char fill6[] = { 1, 1,
                           1, 0};
   static char fill7[] = { 1, 0, 0, 0, 0, 0,
                           1, 0, 0, 0, 0, 0,
                           1, 1, 1, 1, 0, 0,
                           0, 0, 0, 1, 0, 0,
                           0, 0, 0, 1, 0, 0,
                           0, 0, 0, 1, 1, 1};
   static char fill8[] = { 0, 0, 0, 0, 1,
                           0, 0, 0, 1, 0,
                           0, 0, 1, 0, 0,
                           0, 1, 0, 0, 0,
                           1, 0, 0, 0, 0};
   static char fill9[] = { 0, 0, 1, 0, 0};

   static char fill10[] ={ 1, 0, 0, 0, 1,
                           0, 1, 0, 1, 0,
                           0, 0, 1, 0, 0,
                           0, 0, 0, 0, 0 };
   static char fill11[] ={ 0, 0, 0, 0, 0, 0,
                           0, 1, 1, 1, 1, 0,
                           0, 1, 0, 0, 1, 0,
                           0, 1, 0, 0, 1, 0,
                           0, 1, 1, 1, 1, 0,
                           0, 0, 0, 0, 0, 0};
   static char fill12[] ={ 1, 0, 0, 0,
                           0, 1, 0, 0,
                           0, 0, 1, 0,
                           0, 1, 0, 0,
                           1, 0, 0, 0 };
   static char fill13[] ={ 0, 0, 1,
                           0, 1, 0,
                           1, 0, 0};
   static char fill14[] ={ 1, 0, 1,
                           0, 1, 0,
                           1, 0, 1};
   static char fill15[] ={ 1, 1, 0, 0,
                           1, 1, 0, 0,
                           0, 0, 1, 1,
                           0, 0, 1, 1};
   static char fill16[] ={ 1, 1, 1, 1, 1,
                           1, 0, 0, 0, 1,
                           1, 0, 0, 0, 1,
                           1, 0, 0, 0, 1,
                           1, 1, 1, 1, 1};
   static char fill17[] ={ 1, 1, 1, 0, 0, 0,
                           1, 1, 1, 0, 0, 0,
                           1, 1, 1, 0, 0, 0,
                           0, 0, 0, 1, 1, 1,
                           0, 0, 0, 1, 1, 1,
                           0, 0, 0, 1, 1, 1};
   static struct fill_pattern template[PATS] = {
      { 1, 1, fill1},     /* solid color */
      { 3, 3, fill1},     /* grey */
      { 5, 5, fill1},     /* light grey */
      { 1, 3, fill2},     /* horizontal lines */
      { 5, 5, fill3},     /* left to right diagonal */
      { 3, 3, fill4},     /* grid */
      { 5, 5, fill5},     /* small squares */
      { 2, 2, fill6},     /* 3/4 */
      { 6, 6, fill7},     /* diagonal wave */
      { 5, 5, fill8},     /* right to left diagonal */

      { 5, 1, fill9},     /* vertical lines */
      { 5, 4, fill10},    /* horizontal wave */
      { 6, 6, fill11},    /* large squares */
      { 2, 2, fill1},     /* dark grey */
      { 4, 4, fill1},     /* medium grey */
      { 4, 5, fill12},    /* vertical wave */
      { 3, 3, fill13},    /* close diagonal */
      { 3, 3, fill14},    /* x pattern */
      { 3, 1, fill2},     /* close vertical lines */
      { 4, 4, fill15},    /* small checker board */
      { 5, 5, fill16},    /* wide grid */
      { 6, 6, fill17}     /* large checker board */
      };

   char startcolor;
   char color;
   int index, tpl, size, i;
   struct fill_pattern *fill_data, *fill_ptr;
   char *p, *q;

   if (screen_data->colors == 2 && sections < PATS) return template;
   /* create a set of patterns using colors */
   fill_ptr = fill_data = calloc(sections,sizeof(struct fill_pattern));
   index = 0;
   /* first use each available solid color */
   for (color = 1; color < screen_data->colors; ++color) {
      if (index < sections) {
         fill_ptr->height = 1;
         fill_ptr->width = 1;
         fill_ptr->pattern = calloc(1,sizeof(char));
         *(fill_ptr->pattern) = color;
         ++index;
         ++fill_ptr;
         }
      else color = (char) screen_data->colors;
      }
   color = startcolor = 1;
   tpl = 1;
   while (index < sections) {
      if (color >= screen_data->colors) color = 1;
      if (tpl >= PATS) {
         /* repeat template starting with next color */
         tpl = 1;
         if (++startcolor >= screen_data->colors) startcolor = 1;
         color = startcolor;
         }
      fill_ptr->height = template[tpl].height;
      fill_ptr->width = template[tpl].width;
      size = template[tpl].height * template[tpl].width;
      fill_ptr->pattern = p = calloc(size,sizeof(char));
      q = template[tpl].pattern;
      for (i = 0; i < size; ++i)
         if (*q++ != 0) *p++ = color; else *p++ = 0;
      ++color;
      ++tpl;
      ++fill_ptr;
      ++index;
      }
   return fill_data;
#undef PATS
   }
