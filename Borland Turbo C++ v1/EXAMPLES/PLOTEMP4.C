/* PLOTEMP4.C--Example from Chapter 7 of User's Guide */

/* This program creates a table and a bar chart plot from a
   set of temperature readings */

#include <conio.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

/* Prototypes */

void   get_temps(void);
void   table_view(void);
void   min_max(int num_vals, int vals[], int *min_val, int *max_val);
float  avg_temp(int num_vals, int vals[]);
void   graph_view(void);
void   save_temps(void);
void   read_temps(void);

/* Global defines */

#define TRUE      1
#define READINGS  8

/* Global data structures */

int temps[READINGS];

int main(void)
{
   while (TRUE)
   {
      printf("\nTemperature Plotting Program Menu\n");
      printf("\tE - Enter temperatures for scratchpad\n");
      printf("\tS - Store scratchpad to disk\n");
      printf("\tR - Read disk file to scratchpad\n");
      printf("\tT - Table view of current data\n");
      printf("\tG - Graph view of current data\n");
      printf("\tX - Exit the program\n");
      printf("\nPress one of the above keys: ");

      switch (toupper(getche()))
      {
	 case 'E': get_temps();  break;
	 case 'S': save_temps(); break;
	 case 'R': read_temps(); break;
	 case 'T': table_view(); break;
	 case 'G': graph_view(); break;
	 case 'X': exit(0);
      }
   }
}

/* Function definitions */
void  get_temps(void)
{
   char inbuf[130];
   int reading;

   printf("\nEnter temperatures, one at a time.\n");
   for (reading = 0; reading < READINGS; reading++)
   {
      printf("\nEnter reading # %d: ", reading + 1);
      gets(inbuf);
      sscanf(inbuf, "%d", &temps[reading]);

      /* Show what was read */
      printf("\nRead temps[%d] = %d", reading, temps[reading]);
   }
}

void  table_view(void)
{
   int reading, min, max;

   clrscr();                                  /* clear the screen */
   printf("Reading\t\tTemperature(F)\n");

   for(reading = 0; reading < READINGS; reading++)
      printf("%d\t\t\t%d\n", reading + 1, temps[reading]);

   min_max(READINGS, temps, &min, &max);
   printf("Minimum temperature: %d\n", min);
   printf("Maximum temperature: %d\n", max);
   printf("Average temperature: %f\n", avg_temp(READINGS, temps));
}

void  min_max(int num_vals, int vals[], int *min_val, int *max_val)
{
   int reading;

   *min_val = *max_val = vals[0];

   for (reading = 1; reading < num_vals; reading++)
   {
      if (vals[reading] < *min_val)
	 *min_val = (int)&vals[reading];
      else if (vals[reading] > *max_val)
	 *max_val = (int)&vals[reading];
   }
}

float avg_temp(int num_vals, int vals[])
{
   int reading, total = 1;

   for (reading = 0; reading < num_vals; reading++)
      total += vals[reading];

   return (float) total/reading; /* reading equals total vals */
}

void  graph_view(void)
{
   printf("\nExecuting graph_view().\n");
}

void  save_temps(void)
{
   printf("\nExecuting save_temps().\n");
}

void  read_temps(void)
{
   printf("\nExecuting read_temps().\n");
}
