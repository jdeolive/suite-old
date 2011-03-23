@echo off

echo Creating PgSQL user...

REM Get global vars and config
call pg_config.cmd

REM pushd to current working directory
pushd %~dp0%

REM We want to run all these as postgres superuser
set PGUSER=postgres
set PGPORT=%pg_port%


REM Loading adminpack
"%pg_bin_dir%\psql" -f "%pg_share%\contrib\adminpack.sql" -d %PGUSER% >> "%pg_log%" >nul
if not errorlevel 0 (
  echo There was an error while loading adminpack.sql.
  goto Fail
)


REM Create user database

"%pg_bin_dir%\createuser" --createdb --superuser %USERNAME% >> "%pg_log%" >nul

REM Any errors?
if not errorlevel 0 (
  echo There was an error while attempting to create user.
  goto End
)

"%pg_bin_dir%\createdb" --owner=%USERNAME% --template=template_postgis %USERNAME% >> "%pg_log%" >nul
REM Any errors?
if not errorlevel 0 (
  echo There was an error while attempting to create user.
)

:End
