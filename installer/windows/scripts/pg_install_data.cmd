@echo off

echo Creating Medford database...

REM Get global vars and config
call pg_config.cmd

REM pushd to current working directory
pushd %~dp0%

REM We want to run all these as postgres superuser
set PGUSER=postgres
set PGPORT=%pg_port%

REM Create the Medford Database
call "%pg_bin_dir%\createdb" --owner=%USERNAME% --template=template_postgis medford 
if not errorlevel 0 (
  echo There was an error while creating the Medford database.
  goto Fail
)

REM Create the GeoServer/Analytics Database
call "%pg_bin_dir%\createdb" --owner=%USERNAME% --template=template_postgis geoserver 
if not errorlevel 0 (
  echo There was an error while creating the GeoServer database.
  goto Fail
)

REM Load the SQL files
for /f "tokens=* delims= " %%a in ('dir "%pg_data_load_dir%" /b') do (
  echo Loading file: %%a
  "%pg_bin_dir%\psql" -f "%pg_data_load_dir%\%%a" -d medford -U %USERNAME% >> "%pg_log%" >nul
)
if not errorlevel 0 (
  echo There was an error while loading Medford data tables.
  goto Fail
)

goto End

:Fail
echo Medford database creation failed.

:End

cd ..\bin
