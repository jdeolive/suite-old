@echo off

REM Global variables
set pg_version=8.4
set postgis_version=1.5
set pg_default_port=54321

set pg_data_dir=%USERPROFILE%\.opengeo\pgdata\%USERNAME%
set pg_log=%USERPROFILE%\.opengeo\pgdata\%USERNAME%_pgsql.log

set pg_dir=%CD%\..\pgsql\%pg_version%
set pg_bin_dir=%pg_dir%\bin
set pg_lib_dir=%pg_dir%\lib
set pg_port=%pg_default_port%

set pg_data_load_dir=%CD%\..\pgdata

REM Get the existing pgport number from config.ini
if not exist "%USERPROFILE%\.opengeo\config.ini" goto End

set portini=1
set port=1 
findstr pgsql_port "%USERPROFILE%\.opengeo\config.ini" > "%TEMP%\portini.txt"
set /p portini=<"%TEMP%\portini.txt"
del "%TEMP%\portini.txt"
for /f "tokens=1,2,3 delims=/=" %%a in ("%portini%") do set trash1=%%a&set pg_port=%%b
REM should add a check for bad ports here
:End