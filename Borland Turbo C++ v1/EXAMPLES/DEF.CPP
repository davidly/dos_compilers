// def.cpp:   Implementation of the Definition class
// from Chapter 6 of User's Guide
#include <string.h>
#include "def.h"

void Definition::put_word(char *s)
{
   word = new char[strlen(s)+1];
   strcpy(word,s);
   nmeanings = 0;
}

void Definition::add_meaning(char *s)
{
   if (nmeanings < Maxmeans)
   {
      meanings[nmeanings] = new char[strlen(s)+1];
      strcpy(meanings[nmeanings++],s);
   }
}

char * Definition::get_meaning(int level, char *s)
{
   if (0 <= level && level < nmeanings)
      return strcpy(s,meanings[level]);
   else
      return 0;                                // line 27
}
