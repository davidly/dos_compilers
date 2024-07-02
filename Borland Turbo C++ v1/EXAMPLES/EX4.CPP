// ex4.cpp:   Default arguments and Pass-by-reference
// from Chapter 6 of User's Guide
#include <iostream.h>
#include <ctype.h>

int get_word(char *, int &, int start = 0);

main()
{
   int word_len;
   char *s = "  These words will be printed one-per-line  ";

   int word_idx = get_word(s,word_len);           // line 13
   while (word_len > 0)
   {
      cout.write(s+word_idx, word_len);
                cout << "\n";
      //cout << form("%.*s\n",word_len,s+word_idx);
      word_idx = get_word(s,word_len,word_idx+word_len);
   }
}

int get_word(char *s, int& size, int start)
{
   // Skip initial whitespace
   for (int i = start; isspace(s[i]); ++i);
   int start_of_word = i;

   // Traverse word
   while (s[i] != '\0' && !isspace(s[i]))
      ++i;
   size = i - start_of_word;
   return start_of_word;
}
