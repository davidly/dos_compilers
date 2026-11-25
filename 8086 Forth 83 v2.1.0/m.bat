@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem F83 reads the benchmark as keystrokes from redirected input and polls for them.
rem -x makes that polling (and the timer) follow emulated time, so the cycle count
rem doesn't depend on how fast the host is. Needs an ntvdm with -x.

ntvdm -x -r:. -c -p F83.COM <%1.F
