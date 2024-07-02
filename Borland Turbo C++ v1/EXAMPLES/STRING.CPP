//STRING.CPP--Example from Chapter 5 of User's Guide */

#include <iostream.h>
#include <string.h>

class String {
   char *char_ptr;   // pointer to string contents
   int length;       // length of string in characters
public:
   // three different constructors
   String(char *text);           // constructor using existing string
   String(int size = 80);        // creates default empty string
   String(String& Other_String); // for assignment from another
                                 // object of this class
   ~String() {delete char_ptr;};
   int Get_len (void);
   void Show (void);
};

String::String (char *text)
{
   length = strlen(text);  // get length of text
   char_ptr = new char[length + 1];
   strcpy(char_ptr, text);
};

String::String (int size)
{
   length = size;
   char_ptr = new char[length+1];
   *char_ptr = '\0';
};

String::String (String& Other_String)
{
   length = Other_String.length;       // length of other string
   char_ptr = new char [length + 1];   // allocate the memory
   strcpy (char_ptr, Other_String.char_ptr); // copy the text
};

int String::Get_len(void)
{
   return (length);
};

void String::Show(void)
{
   cout << char_ptr << "\n";
};

main ()                                // test the functions
{
   String AString ("Allocated from a constant string.");
   AString.Show();

   String BString;             // uses default length
   cout << "\n" << BString.Get_len() << "\n" ; //display length
   BString = "This is BString";

   String CString(BString);    // invokes the third constructor
   CString.Show();             // note its contents
}
