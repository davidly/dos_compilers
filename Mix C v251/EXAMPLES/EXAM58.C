#define DAYPHCORR  10;
#define LENCYCLE  28.3;

main()     /* Example 5.8 */
{
   int daynumber, intphase;
   int startphase, phase, month, day, year;
   double realphase, phasecorrection;

   printf(" *** Lunar Phase calculation program ***\n");
   printf(" Enter the date (mm/dd/yy):");
   scanf("%d/%d/%d ",&month,&day,&year);
   startphase = ((year - 78) * 365) + DAYPHCORR;
   switch(month) {
      case 1:  daynumber = 1;
               break;
      case 2:  daynumber = 32;
               break;
      case 3:  daynumber = 60;
               break;
      case 4:  daynumber = 91;
               break;
      case 5:  daynumber = 121;
               break;
      case 6:  daynumber = 152;
               break;
      case 7:  daynumber = 182;
               break;
      case 8:  daynumber = 213;
               break;
      case 9:  daynumber = 243;
               break;
      case 10:  daynumber = 274;
               break;
      case 11:  daynumber = 304;
               break;
      case 12:  daynumber = 334;
               break;
   }

   startphase += daynumber + day;
   realphase = startphase / LENCYCLE;
   intphase = realphase;       /* truncate the result */
   realphase -= intphase;
   phase = realphase * LENCYCLE;
   switch (phase){
      case 1: case 2: case 3: case 4: case 5: case 6: case 7:
         printf("The moon is in its first quarter.\n");
         break;
      case 15: case 16: case 17: case 18: case 19:
      case 20: case 21:
         printf("The moon is in its third quarter.\n");
         break;
        /* labels don't have to be in order */
      case 8: case 9: case 10: case 11: case 12:
      case 13: case 14:
         printf("The moon is in its second quarter.\n");
         break;
      case 22: case 23: case 24: case 25: case 26:
      case 27: case 28:
         printf("The moon is in its fourth quarter.\n");
         break;
     }
}

