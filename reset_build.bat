@echo off

echo Resetting build directories and installed assets...
echo ...Are you sure? (Y/N)
set INPUT=
set /P INPUT=Type input: %=%

If /I "%INPUT%"=="y" goto yes 
goto no

:yes
rmdir /S /Q buildtrees
rmdir /S /Q installed
rmdir /S /Q packages

echo --- Builds, pacakges, and installed binaries reset! ---
goto last

:no
echo Aborting!

:last