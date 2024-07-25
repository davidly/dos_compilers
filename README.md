# dos_compilers
MS-DOS compilers, assemblers, and interpreters

The license for this repo applies to code I wrote for this repo including versions of the sieve, e, ttt, and tm benchmarks and the build scripts to invoke the tools. The various DOS tools and documentation each have their own respective license terms. In a few cases I used the sieve benchmark that shipped with the tools, so obviously those copies fall under the license of the respective tool.

I do not own copyright for any of these tools. This repo is simply an aggregation of the tools to ease testing of my NTVDM DOS 3.3 emulator.

In some cases where required I've copied an assembler or linker that did not ship with a given compiler into folders so binaries can be produced. These tools belong to their respective owners.

These tools are available for download from many sites on the internet. They are often in forms that make their extraction and/or use difficult. This repo simplifies the process.

**If you own the copyright to any of these tools and want me to take them down, please let me know and I'll do so ASAP. It's not my intention to pirate anyone's software.**

I cannot vouch that any of these tools matches their official distribution form. Many of these were apparently taken from snapshots on peoples' machines through the years and include changes, files, and/or configuration not found in a pristine distribution. 

In some cases I've included user manuals in PDF form that I've found online for the various compilers. They sometimes match the version and sometimes not, but they are always helpful.

I can vouch that the m.bat/m.sh script in each folder builds working benchmark binaries using NTVDM on Windows, Linux, and MacOS. In the cases of tools that can't be invoked via the command-line (e.g. Turbo Pascal), those tools also produce working benchmark binaries in NTVDM.

It is my intention to show each tool in its best light with respect to the benchmarks. If you know of better optimization flags or ways to improve the benchmark source code for a given tool, please feel free to submit a pull request or open an issue. That said, I want to avoid cheap hacks like using peek/poke in BASIC instead of variables.

The benchmarks include:
  * sieve: The classic from BYTE Magazine that counts prime numbers.
  * e: Computes the irrational number e to 192 digits.
  * ttt: proves you can't win at tic-tac-toe if the opponent is competent
  * tm: test malloc. This calls malloc/calloc/free in the C runtime to measure performance. It's C-only and many C compilers can't run it.

To run the compilers on Windows, use the m.bat script in each folder. Sometimes m.bat is in a subfolder named "bin" or "code". On Linux or MacOS use m.sh. You may need to "chmod 777 m.sh" before you can invoke it. For example (on Windows):
  * m sieve
  * m e
  * m ttt
    
To run the resulting apps, use NTVDM's -c flag to force console mode and -p flag to show performance information. The interpreters have other modes for running; see their respective m.bat/m.sh files for details.

  * ntvdm -c -p sieve
  * ntvdm -c -p e
  * ntvdm -c -p ttt
    
The Borland Pascal (v1 through v3) products don't support command-line builds, so you have to run the apps, load the source file, and build manually. Same for ZBasic and QuickBASIC v2 and v3. For QuickBASIC v2 you must use some emulator other than NTVDM to build; that version directly accesses keyboard hardware in a way that's not emulated in NTVDM. DOSBOX works great.

The ttt benchmark does not run with Microsoft COBOL v1 or v2 because they don't support recursive PERFORM statements.

If you're running Linux or MacOS and see perplexing compilation errors, it could be your source files don't have cr/lf line separators. Use unix2dos to add them; some of these compilers require them. Some compilers require a ^Z / 0x1a at the end of files; CB86 is an example. Again, if you see build errors this may be the problem.

Here are runtimes for the benchmarks in milliseconds for a 4.77Mhz 8086 (not 8088) as emulated by [NTVDM](https://github.com/davidly/ntvdm)

![runtimes](https://github.com/user-attachments/assets/07bd567d-96e4-456c-a052-82d1f04d2e01)


