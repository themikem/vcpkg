@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%~dp0scripts\bootstrap.ps1' -toolsetVer 14.11 -defaultTriplet X64_WINDOWS}"
