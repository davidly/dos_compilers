powerc v2 loads pco.exe to optimize object files after compilation. Before doing so it frees
RAM to make room. But it doesn't relocate the stack, which is sitting in freed RAM that gets
reused by pco.exe. When pco is done there is a crash because the return address is in trashed
stack. This somehow works in vanilla DOS. ntvdm has a workaround for pc.exe

