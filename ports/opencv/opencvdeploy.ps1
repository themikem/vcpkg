# Note: This function signature and behavior is depended upon by applocal.ps1

function deployOpenCV([string]$targetBinaryDir, [string]$installedDir, [string]$targetBinaryName) {
    if ($targetBinaryName -like "opencv_videoio*.dll") {
        if(Test-Path "$installedDir\bin\opencv_ffmpeg341_64.dll") {
            Write-Verbose "  Deploying 64-bit OpenCV FFMPEG Wrapper DLL"
            deployBinary "$targetBinaryDir" "$installedDir\bin" "opencv_ffmpeg341_64.dll"
        }

        if(Test-Path "$installedDir\bin\opencv_ffmpeg341.dll") {
            Write-Verbose "  Deploying OpenCV FFMPEG Wrapper DLL"
            deployBinary "$targetBinaryDir" "$installedDir\bin" "opencv_ffmpeg341.dll"
        }
    }
}

