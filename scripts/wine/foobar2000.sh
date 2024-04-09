#!/bin/bash

progName="foobar2000"
progPrefix="$HOME/.wine"
progHome="$progPrefix/drive_c/Program Files/foobar2000"
progBin="$progName.exe"

# Switches: use -something instead of /something to avoid confusion with Unix paths
# Also convert Unix paths to Windows paths.
declare -a args

for arg; do
	if [[ "${arg:0:1}" = "-" ]]; then
		args+=("${arg/#-//}")
	else
		args+=("$(winepath -w "$arg")")
	fi
done

# wine "$progHome/$progBin" "${args[@]}"
WINEPREFIX="$progPrefix" wine "$progHome/$progBin" "${args[@]}"
