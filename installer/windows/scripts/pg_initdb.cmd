@echo off
echo.

echo Initializing PgSQL database...

:: Get global vars and config
call pg_config.cmd

:: pushd to current working directory
pushd %~dp0%

:: Check for bin dir
if not exist "%pg_bin_dir%" (
  echo Error: PgSQL bin directory not found!
  goto End
)  

:: Check for exisitng pg data directory
if not exist "%pg_data_dir%\PG_VERSION" (
  mkdir "%pg_data_dir%" 2>nul
  "%pg_bin_dir%\initdb.exe" --pgdata="%pg_data_dir%" --username=postgres --encoding=UTF8 >nul 2>nul
) else (
  :: nothing to do
  echo Error: PgSQL data directory already created.
  goto End
)

:: Any errors?
if not errorlevel 0 (
  echo There was an error while running initdb.
) 

:End