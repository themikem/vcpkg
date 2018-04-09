@echo off
@::!/dos/rocks
@echo off
goto :init

:header
    echo %__NAME% v%__VERSION%
    echo This script will build the VCPKG executable and copy it to 
    echo the current directory.
    goto :eof

:usage
    echo USAGE:
    echo   %__BAT_PATH%%__BAT_NAME% [flags]
    echo.
    echo.  /?, --help           shows this help
    echo.  /v, --version        shows the version
    echo.  /e, --verbose        shows detailed output
    echo.  -d, --default value  specifies a default triplet to use for all builds (e.g. X64_WINDOWS)
    echo.  -t, --toolset value  specifies an explicit version of the toolchain to use for all builds (passed to vcvarsall.bat via vcvars_ver parameter)
    echo.  
    goto :eof

:version
    if "%~1"=="full" call :header & goto :eof
    echo %__VERSION%
    goto :eof

:init
    set "__NAME=VCPKG Bootstrap Script"
    set "__VERSION=1.1"
    set "__YEAR=2018"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"

    set "OptHelp="
    set "OptVersion="
    set "OptVerbose="

    set "UnNamedArgument="
    set "DefaultTriplet="
    set "ToolsetVer="

:parse
    if "%~1"=="" goto :validate

    if /i "%~1"=="/?"         call :header                              & call :usage "%~2" & goto :end
    if /i "%~1"=="-?"         call :header                              & call :usage "%~2" & goto :end
    if /i "%~1"=="--help"     call :header                              & call :usage "%~2" & goto :end

    if /i "%~1"=="/v"         call :version                             & goto :end
    if /i "%~1"=="-v"         call :version                             & goto :end
    if /i "%~1"=="--version"  call :version full                        & goto :end

    if /i "%~1"=="/e"         set "OptVerbose=yes"                      & shift & goto :parse
    if /i "%~1"=="-e"         set "OptVerbose=yes"                      & shift & goto :parse
    if /i "%~1"=="--verbose"  set "OptVerbose=yes"                      & shift & goto :parse

    if /i "%~1"=="-d"         set "DefaultTriplet=-defaultTriplet %~2"  & shift & shift & goto :parse
    if /i "%~1"=="--default"  set "DefaultTriplet=-defaultTriplet %~2"  & shift & shift & goto :parse

    if /i "%~1"=="-t"         set "ToolsetVer=-toolsetVer %~2"          & shift & shift & goto :parse
    if /i "%~1"=="--toolset"  set "ToolsetVer=-toolsetVer %~2"          & shift & shift & goto :parse

    if not defined UnNamedArgument     set "UnNamedArgument=%~1"        & shift & goto :parse

    shift
    goto :parse

:invalid_argument
    call :header
    call :usage
    echo.
    echo ****                                   ****
    echo ****    INVALID ARGUMENT: %UnNamedArgument%
    echo ****                                   ****
    echo.
    goto :eof

:validate
    REM TODO check for existance of toolchain
    if defined UnNamedArgument call :invalid_argument & goto :end
    if "%DefaultTriplet%"=="-defaultTriplet " call :invalid_argument & goto :end
    if "%ToolsetVer%"=="-toolsetVer " call :invalid_argument & goto :end

:main
    if defined OptVerbose (
        echo Verbose - %__BAT_PATH% -
        powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%__BAT_PATH%scripts\bootstrap.ps1' -verbose %ToolsetVer% %DefaultTriplet%}"
    ) else (
        powershell.exe -NoProfile -ExecutionPolicy Bypass "& {& '%__BAT_PATH%scripts\bootstrap.ps1' %ToolsetVer% %DefaultTriplet%}"
    )

:end
    call :cleanup
    exit /B

:cleanup
    REM The cleanup function is only really necessary if you
    REM are _not_ using SETLOCAL.
    set "__NAME="
    set "__VERSION="
    set "__YEAR="

    set "__BAT_FILE="
    set "__BAT_PATH="
    set "__BAT_NAME="

    set "OptHelp="
    set "OptVersion="
    set "OptVerbose="

    set "UnNamedArgument="
    set "DefaultTriplet="
    set "ToolsetVer="

    goto :eof