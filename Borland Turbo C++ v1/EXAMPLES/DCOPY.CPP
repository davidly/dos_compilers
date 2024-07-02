/* DCOPY.CPP -- Example from Chapter 5 of User's Guide */

/* DCOPY source-file destination-file                  *
 * copies existing source-file to destination-file     *
 * If latter exists, it is overwritten; if it does not *
 * exist, DCOPY will create it if possible             *
 */

#include <iostream.h>
#include <process.h>    // for exit()
#include <fstream.h>    // for ifstream, ofstream

main(int argc, char* argv[])  // access command-line arguments
{
   char ch;
   if (argc != 3)      // test number of arguments
   {
      cerr << "USAGE: dcopy file1 file2\n";
      exit(-1);
   }

   ifstream source;    // declare input and output streams
   ofstream dest;

   source.open(argv[1],ios::nocreate); // source file must be there
   if (!source)
   {
      cerr << "Cannot open source file " << argv[1] <<
	       " for input\n";
      exit(-1);
   }
   dest.open(argv[2]);   // dest file will be created if not found
			 // or cleared/overwritten if found
   if (!dest)
   {
      cerr << "Cannot open destination file " << argv[2] <<
	      " for output\n";
      exit(-1);
   }

   while (dest && source.get(ch)) dest.put(ch);

   cout << "DCOPY completed\n";

   source.close();        // close both streams
   dest.close();
}



