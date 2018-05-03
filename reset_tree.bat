@echo off

echo Resetting build directories...
call .\reset_build.bat

echo Resetting downloads directories and assets...
echo ...Are you sure? (Y/N)
set INPUT=
set /P INPUT=Type input: %=%

If /I "%INPUT%"=="y" goto yes 
goto no

:yes
rmdir /S /Q downloads

echo --- Tree cleaned and reset ---
goto end2

:no
echo Aborted!

:end2