@echo off
setlocal

ntvdm -r:. -t qpl %1.pas
