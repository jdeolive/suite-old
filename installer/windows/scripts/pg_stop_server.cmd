@echo off

echo Stopping PgSQL...

:: Get global vars and config
call pg_config.cmd

:: pushd to current working directory
pushd "%~dp0%"

:: Check for exisitng pg data directory
if exist "%pg_data_dir%\PG_VERSION" (
  :: Stop the database
  "%pg_bin_dir%\pg_ctl" stop --pgdata "%pg_data_dir%" --log "%pg_log%" --silent -m fast 
) else (
  :: nothing to do
  echo Error: PgSQL data directory not found.
)
popd
