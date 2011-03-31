@echo off
echo.

:: Check for one argument, display usage and quit if not found

if "%1" == "" (
  echo Sorry, one argument is required.
  goto Usage
)

:: pushd to current working directory
pushd "%~dp0%"

:: Get global vars
call pg_config.cmd

:: Start
if "%1" == "start" (

  if exist "%pg_data_dir%\PG_VERSION" (
  :: If run before, just start server
    call pg_start_server.cmd
  ) else (
  :: If never run before, do initialization
    echo Setting up PostGIS for the first time...
    call pg_initdb.cmd
    call pg_start_server.cmd
    call pg_install_template.cmd
    call pg_install_user.cmd
    call pg_install_data.cmd
	echo.
	echo PostGIS setup finished.
	echo.
  )
  goto Done
)


:: Stop
if "%1" == "stop" (
  call pg_stop_server.cmd
  goto Done
)



:Usage
:: Display usage 
echo.
echo Usage:
echo    postgis ^[start^|stop^]
goto End

:Done
cd ..

:End

