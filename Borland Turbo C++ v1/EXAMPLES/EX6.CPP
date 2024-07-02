// ex6.cpp:   Using the Dictionary class
// from Chapter 6 of User's Guide
#include <iostream.h>
#include "diction.h"

main()
{
   Dictionary d(5);
   char *word = "class";
   char *indef[4] =
     {"a body of students meeting together to study the same",
      "subject a group sharing the same economic status",
      "a group, set or kind sharing the same attributes",
      0};
   char *outdef[4];

   d.add_def(word,indef);
   cout << word << ":\n\n";
   int ndef = d.get_def(word,outdef);
   for (int i = 0; i < ndef; ++i)
      cout << (i+1) << ": " << outdef[i] << "\n";
}
