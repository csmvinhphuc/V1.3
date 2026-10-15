@echo off
rem V1.3 Online Launcher cho CMD
rem Cach dung: V1.3-Online.bat [-Version v1.3] [-NoRun]
set URL=https://raw.githubusercontent.com/csmvinhphuc/V1.3/main/V1.3-Online.ps1
if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "irm '%URL%' | iex"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([ScriptBlock]::Create((irm '%URL%'))) %*"
)
