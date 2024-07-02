Changes to CC:

1/9/92 MWS
	Added -x option to generate function prototypes in the compiler.
	Look for references to the OutProtos flag to see the relevant code.

1/12/92 MWS
	Added -w option to generate preprocessed source file (i.e., it just
	preprocesses the input file and writes out the result).  Look for
	references to the OutPrep flag to see the relevant code.

1/16/92 MWS
	Added -f option to compiler to generate prototypes for static functions.
	The -x option now generates prototypes only for non-statics.

1/16/92 MWS
	Kludged autoprototyping code to distinguish between INT and SHORT
	types.  Look for OutProtos being OR'd with 4 in the code to see
	what's going on.

4/9/92 -------------- Released v5.2a beta --------------------------

4/21/92 jd: print_asm_line() 
	%% in inline assembler was trashing chrcls table.

4/21/92 jd: makquest() and doif()
	added checks for condition of type void for if() statement 
	and ?: operator.

9/8/92 jd: 
	cc was not generating correct prototype for a function's union argument.

9/9/92 jd: ptype() & declsym()
	cc was not generating correct prototype for a function that returned
	a long or ulong.

	cc didn't generate correct prototypes when program was compiled to use
	large data memory model.

9/11/92 jd: cinit()
	cc didn't allow static initializations like
		long a = (long)"b";

9/11/92 jd: multidef() refs&def
	cc put out screwy msg for multi-defined symbols

9/14/92 jd: pbstring()
	__FILE__ macro was wrong if input filename had backslashes.

9/14/92 jd: decllist()
	cc didn't report error if struct or union had multidefined symbol.

9/14/92 jd: options(), makcall()
	Added -m option to issue warning if a function is called without a
	prototype for it being in scope.

9/15/92 jd: peek(), pushback(), token()
	cc didn't accept "struct mystr far" but did accept "far struct mystr".

9/15/92 cm: fixed earlier
	cc didn't report error but generated bad code for:
		void f(void);
		...
		if (f())
			...

9/15/92 jd: addfunc()
	cc didn't report error for declaration of huge function, but generated
	near calls to it. Now treating such decls as an error.

9/15/92 jd: verror.c
	error msg 157 applies to data as well as functions.

9/16/92 jd: cinit()
	Don't allow initialization of static ptr to auto:
		m(){int i; static int *ip=&i;}

9/16/92 cm: fixed earlier
	cc gave error 86 "null dimension in array" for
		typedef int arr[];

9/17/92 jd: newfunc()
	cc generated bad debug record for:
		f(long){}

9/23/92 jd: options(), etc
	-o option didn't work when using +j option to generate OMF

9/23/92 jd: bmain.c, cstat.c
	Changed cc so that both -x and -f can be specified at once, to get
	prototypes for both static and global functions.


10/4/92 ---------------- Released v5.2a beta 2 ----------------------------


10/5/92 jd: execvp()
	Relinked 'cc' to use fixed execvp() - previous execvp() didn't always 
	correctly search all directories specified in PATH.

10/6/92 jd: cinit()
	cc v4.10d allowed aggregate initializers to have nothing between the braces,
	which allowed cc to do the correct thing for:
		struct str { char a[5], b[5], c[5]} mystr = { {}, {}, "abc" };
	The v5.2a cc did not allow this, in conformance with ANSI. The compiler
	has been changed so that this is disallowed when in strict ANSI mode
	(i.e. compiler with -ansi), and allowed otherwise.

10/26/92 jd: newfunc()
	when generating prototypes, cc did not correctly handle functions defined
	using the new syntax (e.g. void f(int a){} instead of void f(a)int a;{} )
