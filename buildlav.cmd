@echo off

setlocal
pushd "%~dp0"

if "%~1"=="" goto :eof

setlocal
call :env_check || goto :finally
endlocal

set "S_ARCH=%~1"
set "S_CONFIG=%~2"
title Building %S_ARCH% %S_CONFIG%
call "%F_VCVAR%" %S_ARCH%

call :build_zlib

call :build_ffmpeg

call :build_lav

:finally
popd
endlocal

goto :eof

:build_zlib
::==================

mkdir "%S_ARCH%"

pushd "%S_ARCH%"
nmake -f "%SOURCE_DIR%\win32\Makefile.msc"

set "ZLIB_PATH=%CD%"
set "INCLUDE=%INCLUDE%;%SOURCE_DIR%"
set "LIB=%LIB%;%ZLIB_PATH%"
set "LIBPATH=%LIBPATH%;%ZLIB_PATH%"

popd

goto :eof

:build_ffmpeg
::==================

set "P_NIX_PATH=%CD%\"
call :nix_path
set "P_CWD=%P_NIX_PATH%"

set "P_NIX_PATH=%D_LAV%"
call :nix_path
set "P_LAV=%P_NIX_PATH%"

pushd .
call %C_SHELL% -c "cd /%P_LAV% && /%P_CWD%./buildffmpeg %S_ARCH% %S_CONFIG%"
popd

goto :eof

:build_lav
::==================

set "S_ARCH_SLN=%S_ARCH%"
if "x%S_ARCH_SLN%"=="xx86" set "S_ARCH_SLN=Win32"

pushd .\..\lavfilters
MSBuild.exe LAVFilters.sln /nologo /m /t:Build /property:Configuration=%S_CONFIG%;Platform=%S_ARCH_SLN%
popd

goto :eof

:nix_path
::==================
set "P_NIX_PATH=%P_NIX_PATH::\=/%"
set "P_NIX_PATH=%P_NIX_PATH:\=/%"
set "P_NIX_PATH=%P_NIX_PATH::/=/%"
set "P_NIX_PATH=%P_NIX_PATH://=/%"

goto :eof


:env_check
::==================

call "%F_VCVAR%" 1>NUL 2>&1 || ( echo "F_VCVAR=%F_VCVAR% not found." && exit /b 1 )
call %C_SHELL% -c "exit" 1>NUL 2>&1 || ( echo "C_SHELL=%C_SHELL% not found." && exit /b 1 )
dir "%D_LAV%" 1>NUL 2>&1 || ( echo "D_LAV=%D_LAV% not found." && exit /b 1 )
dir "%SOURCE_DIR%" 1>NUL 2>&1 || ( echo "SOURCE_DIR=%SOURCE_DIR% not found." && exit /b 1 )

exit /b 0
