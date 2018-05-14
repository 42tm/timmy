#!/bin/sh
# Shell script to compile example(s)
# Copyright... nah.

# Show help if no argument is passed
  if [ $# -eq 0 ]
  then
      echo "mkexample.sh - Shell script to compile Timmy example(s)"
      echo
      echo "USAGE"
      echo "-----"
      echo "sh mkexample.sh [-c PROGRAM] [*|FILENAME]"
      echo " -c PROGRAM : Use PROGRAM to compile the source file(s)"
      echo "              Note that PROGRAM must be an executable command."
      echo "              If -c is not specified, Free Pascal Compiler is used."
      echo
      echo "EXAMPLES"
      echo "--------"
      echo "sh mkexample.sh 03.pas        - Compile example 3 using FPC"
      echo "sh mkexample.sh *             - Compile all examples"
      echo "sh mkexample.sh -c opc 01.pas - Compile example 1 using opc"
      exit
  fi

set -f
export pas_compiler=""
export psf=""

# Get compiler and source file(s) to compile
  if [ "$1" = "-c" ]
  then
      if command -v "$2" &>/dev/null;
      then
          export pas_compiler="$2"
          export psf="$3"
      else
          echo "It seems like '$2' is not an executable command."
          exit
      fi
  else
      export pas_compiler="fpc"
      export psf=$1
  fi

# Compile
  if [ "$psf" = "*" ]
  then
      # Take filenames, one by one
        find . -name "*.pas" |
        while read source_file_name
        do
            $pas_compiler $source_file_name &>/dev/null
            wait
        done
  else
      $pas_compiler $psf &>/dev/null
  fi

set +f
# Clean up
  rm *.o &>/dev/null
  unset pas_compiler
  unset psf
