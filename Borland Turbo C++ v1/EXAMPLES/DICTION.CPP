// diction.cpp:   Implementation of the Dictionary class
// from Chapter 6 of User's Guide
#include "diction.h"

int Dictionary::find_word(char *s)
{
   char word[81];
   for (int i = 0; i < nwords; ++i)
      if (stricmp(words[i].get_word(word),s) == 0)
         return i;

   return -1;
}

void Dictionary::add_def(char *word, char **def)
{
   if (nwords < Maxwords)
   {
      words[nwords].put_word(word);
      while (*def != 0)
         words[nwords].add_meaning(*def++);
      ++nwords;
   }
}

int Dictionary::get_def(char *word, char **def)
{
   char meaning[81];
   int nw = 0;
   int word_idx = find_word(word);
   if (word_idx >= 0)
   {
      while (words[word_idx].get_meaning(nw,meaning) != 0)
      {
         def[nw] = new char[strlen(meaning)+1];
         strcpy(def[nw++],meaning);
      }
      def[nw] = 0;
   }

   return nw;
}
