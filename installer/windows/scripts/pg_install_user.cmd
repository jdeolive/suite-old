@echo off

echo Creating PgSQL user...

:: Get global vars and config
call pg_config.cmd

:: pushd to current working directory
pushd %~dp0%

:: We want to run all these as postgres superuser
set PGUSER=postgres
set PGPORT=%pg_port%


:: Loading adminpack
"%pg_bin_dir%\psql" -f "%pg_share%\contrib\adminpack.sql" -d %PGUSER% >> "%pg_log%" >nul
if not errorlevel 0 (
  echo There was an error while loading adminpack.sql.
  goto Fail
)


:: Create user database

"%pg_bin_dir%\createuser" --createdb --superuser %USERNAME% >> "%pg_log%" >nul

:: Any errors?
if not errorlevel 0 (
  echo There was an error while attempting to create user.
  goto End
)

"%pg_bin_dir%\createdb" --owner=%USERNAME% --template=template_postgis %USERNAME% >> "%pg_log%" >nul
:: Any errors?
if not errorlevel 0 (
  echo There was an error while attempting to create user.
)

:End
