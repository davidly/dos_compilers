QUICK C COMPILER OPTIONS
-MEMORY MODEL-
/AS small model (default)
/AC compact model
/AM medium model
/AL large model
/AH huge model
/AT tiny model (.COM files)
-OPTIMIZATION-
/O enable optimization (same as /Ot)
/Od disable optimizations
/Ol enable loop optimizations
/Ot optimize for speed
/Ox max. optimization (/Olt /Gs)
-CODE GENERATION-
/G0 8086 instructions (default)
/G1  186 instructions
/G2  286 instructions
/Gc Pascal style function calls
/Gi incremental compilation
/Gr _fastcall type calls
/Gs no stack checking
/Gt[number] data size threshold
/ND <data segment name>
/NT <text segment name>
-OUTPUT FILES-
/Fe<executable file>
/Fm[map file]
/Fo<object file>
-PREPROCESSOR-
/C don't strip comments
/D<name>[=text] define macro
/E preprocess to stdout
/EP same as /E but no #line
/I<name> add #include path
/P preprocess to file
/U<name> remove predefined macro
/u remove all predefined macros
/X ignore "standard places"
-LANGUAGE-
/Za disable extensions
/Zd line number information
/Ze enable extensions (default)
/Zi symbolic debugging information
/Zl remove default library info
/Zp[n] pack structs on n-byte boundary
/Zr enable pointer checking
/Zs syntax check only
-FLOATING POINT-
/FPi inline with emulator (default)
/FPi87 inline with 8087
-MISCELLANEOUS-
/batch no interactive prompts
/c compile only, no link
/J default char type is unsigned
/nologo no sign-on message
/Tc<file> compile file without .c
/V<string> set version string
/W<number> warning level
-MASM SUPPORT-
/Ta<file> assemble file without .asm
-LINKING-
/F <hex_number> stack size (hex. bytes)
/link [linker_options_and_libraries]
/Lc link compatibility mode executable
/Ln link without C Startup Code
/Lr link compatibility mode executable
