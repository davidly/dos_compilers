#if sizeof(char *) == 4
int _STKSIZ = 8192/16;  /* (in paragraphs) (large data model) */
int _STKRED = 1024;		/* size of RED zone (in bytes) */
#else
int _STKSIZ = 4096/16;  /* (in paragraphs) */
int _STKRED = 2048;		/* size of RED zone (in bytes) */
#endif

int _HEAPSIZ = 4096/16; /* (in paragraphs) */
int _STKLOW = 0;		/* default is stack above heap (small only) */

/**********************
NOTE: The RED zone is used for stack safety checking.  
If the stack is above the heap,
(1) the heap is not allowed within STKRED bytes of the current value
    of the SP; 
(2) if limit checking is enabled (see the cc +b option), SP isn't
    allowed any closer than STKRED bytes to the top of the heap.  

If the stack is below the heap and limit checking is enabled, 
SP isn't allowed any closer than STKRED bytes to _Utop.  

Minimum stack size = 2*_STKRED.  Minimum value for STKRED
should be about 256 bytes.  This allows some margin to issue DOS calls and
allow interrupt handlers to execute.  (Some people think that this should
be > 1k.) 
*********************/
