@echo off

echo Creating Medford database...

:: Get global vars and config
call pg_config.cmd

:: pushd to current working directory
pushd %~dp0%

:: We want to run all these as postgres superuser
set PGUSER=postgres
set PGPORT=%pg_port%
set pgdatalist=%TEMP%\pg_data.txt

:: Create the Medford Database
call "%pg_bin_dir%\createdb" --owner=%USERNAME% --template=template_postgis medford 
if not errorlevel 0 (
  echo There was an error while creating the Medford database.
  goto Fail
)

:: Create the GeoServer/Analytics Database
call "%pg_bin_dir%\createdb" --owner=%USERNAME% --template=template_postgis geoserver 
if not errorlevel 0 (
  echo There was an error while creating the GeoServer database.
  goto Fail
)

:: Load the SQL files
:: Too bad, must create a file listing
dir /b "%pg_data_load_dir%" > "%pgdatalist%"
:: Schema files first
for /f "tokens=* delims= " %%a in ('findstr _schema "%pgdatalist%"') do (
  echo Loading file: %%a
  "%pg_bin_dir%\psql" -f "%pg_data_load_dir%\%%a" -d medford -U %USERNAME% >> "%pg_log%" >nul
)
if not errorlevel 0 (
  echo There was an error while loading Medford data tables.
  goto Fail
)
:: Non-schema files next
for /f "tokens=* delims= " %%a in ('findstr /vi _schema "%pgdatalist%"') do (
  echo Loading file: %%a
  "%pg_bin_dir%\psql" -f "%pg_data_load_dir%\%%a" -d medford -U %USERNAME% >> "%pg_log%" >nul
)
if not errorlevel 0 (
  echo There was an error while loading Medford data tables.
  goto Fail
)
del "%pgdatalist%"


goto End

:Fail
echo Medford database creation failed.

:End

cd ..\bin
