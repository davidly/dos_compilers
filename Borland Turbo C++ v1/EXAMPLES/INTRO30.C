/* INTRO30.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>
#include <string.h>

typedef struct {
   char name[10];
   float distance;
   float radius;
} planet;

planet mars;

int main()
{
   strcpy(mars.name,"Mars");
   mars.distance = 1.5;
   mars.radius = 0.4;

   printf("Planetary statistics:\n");
   printf("Name: %s\n", mars.name);
   printf("Distance from Sun in AU: %4.2f\n", mars.distance);
   printf("Radius in Earth radii: %4.2f\n", mars.radius);

   return 0;
}
