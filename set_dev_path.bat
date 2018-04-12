@echo off
set VCPKG_PATH=%~dp0

set OLD_PATH=%Path%

set Path=%VCPKG_PATH%installed\x64-windows\bin\
set Path=%Path%;%VCPKG_PATH%installed\x64-windows\lib\
set Path=%Path%;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v9.1\bin\
set Path=%Path%;C:\gstreamer\1.0\x86_64\bin\
set Path=%Path%;%VCPKG_PATH%downloads\cmake-3.11.0-win32-x86\bin\
set Path=%Path%;%VCPKG_PATH%downloads\MinGit-2.17.0-32-bit\cmd\

set Path=%Path%;%OLD_PATH%

echo Path set to %Path%