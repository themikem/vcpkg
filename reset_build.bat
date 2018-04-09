@echo off

echo Resetting build directories & installed assets...
echo ...Are you sure? (Y/N)
set INPUT=
set /P INPUT=Type input: %=%

If /I "%INPUT%"=="y" goto yes 
goto no

:yes
REM rmdir /S /Q buildtrees
REM rmdir /S /Q installed
REM rmdir /S /Q packages

echo --- Builds, pacakges, and installed binaries reset! ---
goto end

:no
echo Aborting!

:end