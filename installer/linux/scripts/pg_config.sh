#
# GLOBALS
#
pg_version=8.4
postgis_version=1.5
pg_default_port=54321

# Read the location of the script file itself
pushd `dirname "$0"` > /dev/null && 
HERE=`pwd` && 
popd > /dev/null

suite_dir=${HERE}/../..
pg_data_root_dir=${suite_dir}/pgdata/
pg_data_dir=${suite_dir}/pgdata/${USER}
pg_log=${suite_dir}/pgdata/${USER}_pgsql.log
pg_data_load_dir=${suite_dir}/suite/pgdata

pg_dir=${suite_dir}/pgsql
pg_bin_dir=${pg_dir}/bin
pg_lib_dir=${pg_dir}/lib
pg_share_dir=`${pg_bin_dir}/pg_config --sharedir`
postgis_share_dir=${pg_share_dir}/contrib/postgis-${postgis_version}

export LD_LIBRARY_PATH="$pg_lib_dir"

#
# FUNCTIONS
#
function pg_check_ini {
  local port
  local ini="$HOME/.opengeo/config.ini"
  # Set defaults
  pg_port=$pg_default_port
  # Read ini
  if [ -f "$ini" ]; then
    # Extract the port number from the pgsql_port line
    port=`grep pgsql_port "$ini" | cut -f2 -d= | tr -d ' '`
    # Make sure we found a number
    if [ "x$port" != "x" ]; then
      # Make sure the number is > 1024
      if [ "$port" -gt 1024 ]; then
        pg_port=$port
      fi
    fi
  fi
}

function pg_check_data {
  # Make root dir
  if [ ! -d "$pg_data_root_dir" ]; then
    mkdir "$pg_data_root_dir"
  fi
  # Is there a data dir?
  if [ -d "$pg_data_dir" ]; then
    # Does is have a PG_VERSION file in it (ie, it's been initdb'ed)
    if [ -f "$pg_data_dir/PG_VERSION" ]; then
      local version=`cat $pg_data_dir/PG_VERSION`
      # Does the version in that file match the version we are running?
      if [ "$version" = "$pg_version" ]; then
        echo "good"
      else
        echo "wrong_version"
        pg_data_version="$version"
      fi
    else
      echo "no_version"
    fi
  else
    echo "no_directory"
  fi
}

function pg_check_bin {
  local exe
  local r
  # Check the existence of all our required utilities in the bin dir
  for exe in psql createlang createuser createdb pg_config pg_ctl
  do 
    local pgexe="$pg_bin_dir/${exe}"
    if [ ! -x "$pgexe" ]; then
      r="missing_$exe"
      break
    fi
  done

  if [ ! -d "$pg_lib_dir" ]; then
    r="missing_lib"
  else
    export LD_LIBRARY_PATH="$pg_lib_dir"
  fi

  if [ ! "$r" ]; then
    echo "good"
  else
    echo $r
  fi
}


