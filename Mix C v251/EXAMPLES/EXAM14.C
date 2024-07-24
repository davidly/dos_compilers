main()            /* Example 1.4 */
{
   /*  declare integer variables  */
   int our_score;
   int their_score;
   int our_touchdowns, our_field_goals;
   int their_tds, their_fgs;

   /*  assign values  */
   our_score = 24;
   their_score = 14;
   our_touchdowns = 3;
   their_tds = 2;
   our_field_goals = 1;
   their_fgs = 0;

/*  print the results of the game  */
   printf("           Home  Visitor\n");
   printf("Score       %d    %d\n",
       our_score, their_score);
   printf("Touchdowns  %d     %d\n",
       our_touchdowns, their_tds);
   printf("Field Goals %d     %d\n",
       our_field_goals, their_fgs);

}
