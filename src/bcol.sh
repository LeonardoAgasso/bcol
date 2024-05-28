#!/bin/bash

# Check if CORES is set, otherwise default to number of available CPU cores
if [ -z "$CORES" ]; then CORES=$(nproc); fi;

# Export the locale settings for consistency
export LC_ALL=C

# Function to process input
process_input() {
    # Process input in parallel, passing all additional arguments to column
    parallel -j "$CORES" --pipe column "$@"
}

# Check if input is provided through a pipe or redirection
if [ -t 0 ]; then
    # No input provided through pipe or redirection
    if [ $# -eq 0 ]; then
        echo "Usage: $(basename "$0") [options] <file>" >&2
        exit 1
    else
        # Read input from file argument
        cat "$1" | process_input "${@:2}"
    fi
else
    # Input provided through pipe or redirection
    process_input "${@:1}"
fi

# Exit with the same exit code as the parallel command
exit $?