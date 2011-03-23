@echo off

echo Starting PgSQL...

REM Get global vars and config
call pg_config.cmd

REM pushd to current working directory
pushd "%~dp0%"

REM Check for exisitng pg data directory
if exist "%pg_data_dir%\PG_VERSION" (

  REM We need to trick pgautovacuum into using the right superuser
  set PGUSER=postgres

  REM Start the database
  "%pg_bin_dir%\pg_ctl" start --pgdata "%pg_data_dir%" --log "%pg_log%" --silent -w -o "-p %pg_port% -i"
) else (
  REM nothing to do
  echo Error: PgSQL data directory not found.

)
popd

