@echo off
set VCPKG_PATH=%~dp0

set PATH=%PATH%;D:\dvt\vcpkg\installed\x64-windows\bin\;D:\dvt\vcpkg\installed\x64-windows\lib
set PATH=%PATH%;C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v9.1\bin
set PATH=%PATH%;C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018.1.156\windows\redist\intel64_win\mkl
set PATH=%PATH%;C:\gstreamer\1.0\x86_64\bin
set PATH=%PATH%;C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2018\windows\redist\intel64\mkl
set PATH=%PATH%;%VCPKG_PATH%downloads\cmake-3.11.0-win32-x86\bin
set PATH=%PATH%;%VCPKG_PATH%downloads\MinGit-2.17.0-32\cmd

echo PATH set to %PATH%