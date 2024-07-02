#include <stream.hpp>
#include <intvec.hpp>

volatile int got_ctrl_c = 0;

int cdecl ctrl_c_handler(struct INT_DATA *)
{
    ++got_ctrl_c;               // just note that one occurred
    return 1;                   // do not chain old handler
}

main()
{
    intvector ctrlc(0x23,ctrl_c_handler);
    char buffer[80];
    
    cout << "Enter a string possibly including ^C: ";
    cout.flush();
    cin >> buffer;
    cout << "\n\n";
    if (got_ctrl_c)
        cout << "There was a ^C in the text you entered\n";
}
