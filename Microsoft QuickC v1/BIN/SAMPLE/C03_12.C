#include <stdio.h>
#include <time.h>
main()
{
   struct tm *current_time;
   time_t long_time;    /* time value */
   time (&long_time);   /* get number of seconds into long_time */
   /* convert to time structure */
   current_time = localtime(&long_time);  
   /* use member-selection operator to access 
      individual element of structure */
   printf ("hour: %d\n", current_time->tm_hour);
}

