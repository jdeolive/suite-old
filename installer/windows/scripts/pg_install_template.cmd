@echo off

echo Creating PgSQL template...

:: Get global vars and config
call pg_config.cmd

:: pushd to current working directory
pushd %~dp0%

"%pg_bin_dir%\pg_config" --sharedir > "%TEMP%\sharedir.txt"
set /p pg_share=<"%TEMP%\sharedir.txt"
del "%TEMP%\sharedir.txt"

if not exist "%pg_share%\contrib\postgis-%postgis_version%\postgis.sql" (
  echo Error: postgis.sql file not found.
  goto Fail
) else (
  set postgis=%pg_share%\contrib\postgis-%postgis_version%\postgis.sql
)

if not exist "%pg_share%\contrib\postgis-%postgis_version%\spatial_ref_sys.sql" (
  echo Error: spatial_ref_sys.sql file not found.
  goto Fail
) else (
  set srs=%pg_share%\contrib\postgis-%postgis_version%\spatial_ref_sys.sql
)

:: We want to run all these as postgres superuser
set PGUSER=postgres
set PGPORT=%pg_port%

"%pg_bin_dir%\createdb" template_postgis >> "%pg_log%" >nul
if not errorlevel 0 (
  echo There was an error while creating template database.
  goto Fail
)

"%pg_bin_dir%\createlang" plpgsql template_postgis >> "%pg_log%" >nul 
if not errorlevel 0 (
  echo There was an error while creating langauge in new template database.
  goto Fail
)

"%pg_bin_dir%\psql" -d template_postgis -f "%postgis%" >> "%pg_log%" >nul
if not errorlevel 0 (
  echo There was an error while loading postgis.sql.
  goto Fail
)

"%pg_bin_dir%\psql" -d template_postgis -f "%srs%" >> "%pg_log%" >nul
if not errorlevel 0 (
  echo There was an error while loading spatial_ref_sys.sql.
  goto Fail
)

"%pg_bin_dir%\psql" -d template_postgis -c "update pg_database set datistemplate = true where datname = 'template_postgis'" >> "%pg_log%"  >nul
if not errorlevel 0 (
  echo There was an error while setting database template flag.
  goto Fail
)

goto End

:Fail
echo Template database creation failed.

:End
