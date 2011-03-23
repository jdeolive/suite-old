@echo off

echo Stopping PgSQL...

REM Get global vars and config
call pg_config.cmd

REM pushd to current working directory
pushd "%~dp0%"

REM Check for exisitng pg data directory
if exist "%pg_data_dir%\PG_VERSION" (
  REM Stop the database
  "%pg_bin_dir%\pg_ctl" stop --pgdata "%pg_data_dir%" --log "%pg_log%" --silent -m fast 
) else (
  REM nothing to do
  echo Error: PgSQL data directory not found.
)
popd
