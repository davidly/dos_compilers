@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem muLISP loads COMMON.LSP and STRUCTUR.LSP ahead of the benchmark: they're combined into
rem LISPRUN.LSP without their ^Z end-of-file characters and (RDS) calls.

del lisprun.lsp 2>nul
copy common.lsp+structur.lsp+%1.lsp lisptmp.lsp >nul
findstr /i /v /c:"(RDS)" lisptmp.lsp >lisprun.lsp
del lisptmp.lsp 2>nul

ntvdm -r:. -c -p mulisp LISPRUN.LSP
del lisprun.lsp 2>nul
