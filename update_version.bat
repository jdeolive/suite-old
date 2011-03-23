@echo off
:: Changes the version number in all pom.xml files

:: Check for command line arguments
if "x%1"=="x" goto usage
if "x%2"=="x" goto usage
if not "x%3"=="x" goto usage

:: Check for sed
sed 2>"%TEMP%\sed.txt"
set /p sedtemp=<"%TEMP%\sed.txt"
del "%TEMP%\sed.txt"
for /f %%a in ("%sedtemp%") do set sedoutput=%%a
if "%sedoutput%" == "'sed'" goto nosed

:: Run the search/replace
for /f "delims=/" %%a in ('dir /s /b pom.xml') do (
  echo %%a
  sed -i "s/<version>%1</<version>%2</g" "%%a"
)

echo Updated version strings in pom.xml files from %1 to %2.
goto end

:nosed
echo.
echo Error: sed not found on path.
goto usage

:usage
echo.
echo Usage:
echo    update_version old_version new_version
goto end

:end