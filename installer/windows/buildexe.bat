@echo off
:: job to build .EXE
:: assumes that
::   http://svn.opengeo.org/suite/trunk/installer
:: has been checked out
:: Also assumes that it is running inside installer\windows

:: Requires two paramters
:: buildexe.bat %repo_path% %revision% %profile%
:: See Usage at bottom
if "x%2"=="x" goto Usage
if not "x%4"=="x" goto Usage
set repo_path=%1
set revision=%2
set profile=%3

:: Start by cleaning up target
rd /s /q ..\..\target\ >nul 2>nul

:: Assemble artifact base URL
set url=http://suite.opengeo.org/builds/%repo_path%

:: Convert slashes to dashes in "repo_path", to be called "repo-path"
for /f "tokens=1,2 delims=\/" %%a in ("%repo_path%") do (
  if not "x%%b"=="x" (
    set repo-path=%%a-%%b
  ) else (
    set repo-path=%%a
  )
)

:: Generate id string (for file names)
if "x%profile%"=="x" (
  set id=%repo-path%-r%revision%
) else (
  set id=%profile%-%repo-path%-r%revision%
)

:: File names
set mainzip=opengeosuite-%id%-win.zip
set dashzip=dashboard-%id%-win32.zip

:: Get the maven artifacts 
echo Downloading %url%/%mainzip% ...
wget %url%/%mainzip% >nul 2>nul || (
  echo Error: File not found
  exit /b 1
)
echo Downloading %url%/%dashzip% ...
wget %url%/%dashzip% >nul 2>nul || (
  echo Error: File not found
  exit /b 1
)

:: Put artifacts in place
mkdir ..\..\target\win 2>nul
unzip %mainzip% -d ..\..\target\win
del %mainzip%
rd /s /q ..\..\target\win\dashboard
unzip %dashzip% -d ..\..\target\win\
del %dashzip%
ren "..\..\target\win\OpenGeo Dashboard" dashboard

:: Get version number
:: Example: "2.1.2" or "2.3-SNAPSHOT"
findstr suite_version ..\..\target\win\version.ini > "%TEMP%\vertemp.txt"
set /p vertemp=<"%TEMP%\vertemp.txt"
del "%TEMP%\vertemp.txt"
for /f "tokens=1,2 delims=/=" %%a in ("%vertemp%") do set trash=%%a&set version=%%b

:: Get revision number, called "rev" here
:: Note that this must be numeric.
:: It is determined differently from what is passed from Hudson
:: since Hudson could pass "latest" as the value for revision.
:: This may be unecessary now (Hudson no longer using "latest")
findstr svn_revision ..\..\target\win\version.ini > "%TEMP%\revtemp.txt"
set /p revtemp=<"%TEMP%\revtemp.txt"
del "%TEMP%\revtemp.txt"
for /f "tokens=1,2 delims=/=" %%a in ("%revtemp%") do set trash=%%a&set rev=%%b

:: Figure out if the version is a release version or a SNAPSHOT/RC
:: Used to pass the correct longversion parameter to NSIS
:: since NSIS longversion must be of the form #.#.#.#

:: First, split the version string on a dash (to check for -SNAPSHOT or -RC)
for /f "tokens=1,2 delims=-" %%a in ("%version%") do set verpredash=%%a&set verpostdash=%%b
:: If a second chunk exists, then it's a -SNAPSHOT or -RC
if not "x%verpostdash%"=="x" goto Snapshot
:: Now check for empty substrings (to check for bad versions)
for /f "tokens=1,2,3,4 delims=." %%a in ("%version%") do set vermajor=%%a&set verminor=%%b&set verpatch=%%c&set vertrash=%%d
:: There must be three substrings here, so check for the third
if "x%verpatch%"=="x" goto Snapshot
:: There can't be a fourth substring, though
if not "x%vertrash%"=="x" goto Snapshot

:: If we made it this far, it's probably in the proper form
set longversion=%version%.%rev%
goto Build
:Snapshot
set longversion=0.0.0.%rev%
goto Build

:Build
:: Now build the EXE with NSIS
@echo Running NSIS (version %version%, longversion %longversion%) ...
makensis /DVERSION=%version% /DLONGVERSION=%longversion% OpenGeoInstaller.nsi

:: Clean up
rd /s /q ..\..\target\

goto End


:Usage
echo.
echo OpenGeo Suite build process
echo.
echo Usage:
echo   buildexe.bat repo_path revision profile
echo Exs:
echo   buildexe.bat branches/2.2.x 1866 ee
echo   buildexe.bat trunk 1898
echo.
exit /b 1



:End

::Unused commands

:: Get today's date
:: for /F "tokens=1* delims= " %%A in ('DATE/T') do set CDATE=%%B
:: for /F "tokens=1,2 eol=/ delims=/ " %%A in ('DATE/T') do set mm=%%B
:: for /F "tokens=1,2 delims=/ eol=/" %%A in ('echo %CDATE%') do set dd=%%B
:: for /F "tokens=2,3 delims=/ " %%A in ('echo %CDATE%') do set yyyy=%%B
:: set todaysdate=%yyyy%-%mm%-%dd%
