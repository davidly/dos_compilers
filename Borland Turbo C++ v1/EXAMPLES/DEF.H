// def.h:   A word definition class
// from Chapter 6 of User's Guide
#include <string.h>

const int Maxmeans = 5;

class Definition
{
   char *word;                    // Word being defined
   char *meanings[Maxmeans];      // Various meanings of this word
   int nmeanings;

public:
   void put_word(char *);
   char *get_word(char *s) {return strcpy(s,word);};  // line 15
   void add_meaning(char *);
   char *get_meaning(int, char *);
};
