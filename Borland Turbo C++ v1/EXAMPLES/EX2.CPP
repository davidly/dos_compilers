// ex2.cpp:   An interactive example
// from Chapter 6 of User's Guide
#include <iostream.h>

main()
{
   char name[16];
   int age;

   cout << "Enter your name: ";
   cin >> name;
   cout << "Enter your age: ";
   cin >> age;

   if (age < 21)
      cout << "You young whippersnapper, " << name << "!\n";
   else if (age < 40)
      cout << name << ", you're still in your prime!\n";
   else if (age < 60)
      cout << "You're over the hill, " << name << "!\n";
   else if (age < 80)
      cout << "I bow to your wisdom, " << name << "!\n";
   else
      cout << "Are you really " << age << ", " << name << "?\n";
}
