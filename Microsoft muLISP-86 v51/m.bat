copy common.lsp+structur.lsp+%1.lsp foo.lsp
REM first remove (rds) twice from foo.lsp
type foo.lsp | findstr /i /B /V (RDS) >bar.lsp
ntvdm -p -c mulisp bar.lsp

