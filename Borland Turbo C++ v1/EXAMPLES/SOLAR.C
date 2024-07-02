/* SOLAR.C--Example from Chapter 4 of User's Guide */

#include <graphics.h>
#include <stdio.h>
#include <string.h>

typedef struct {
   char name[10];
   float distance;
   float radius;
   int color;
   int fill_type;
} planet;

planet solar_system[9];
planet *planet_ptr;
int    planet_num;

int main()
{
   strcpy(solar_system[0].name,"Mercury");
   solar_system[0].distance = 0.4;
   solar_system[0].radius = 0.4;
   solar_system[0].color = EGA_YELLOW;
   solar_system[0].fill_type = EMPTY_FILL;

   planet_ptr = solar_system;
   planet_ptr++;             /* Point to second planet structure */
    strcpy (planet_ptr->name,"Venus");
   planet_ptr->distance = 0.7;
   planet_ptr->radius = 1.0;
   planet_ptr->color = EGA_BROWN;
   planet_ptr->fill_type = SOLID_FILL;

   planet_ptr = solar_system;         /* Reset to first element */
   for (planet_num = 0; planet_num < 2; planet_num++, planet_ptr++) {
      printf("\nPlanetary statistics:\n");
      printf("Name: %s\n", planet_ptr->name);
      printf("Distance from Sun in AU: %4.2f\n",
              planet_ptr->distance);
      printf("Radius in Earth radii: %4.2f\n", planet_ptr->radius);
      printf("Color constant value %d\n", planet_ptr->color);
      printf("Fill pattern constant value %d\n",
             planet_ptr->fill_type);
   }

   return 0;
}
