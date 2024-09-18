#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 CORES [options for column] [file]"
    echo "Options for column are passed directly to the column command."
    exit 1
}

# Function to display version information
version() {
    echo "bcol version 1.0"
    exit 1
}

# Check if -h or -V option is provided
case "$1" in
    "-h"|"--help") usage ;;
    "-V"|"--version") version ;;
esac

# Check if parallel is installed
if ! command -v parallel &> /dev/null
then
    echo "parallel could not be found, please install it first (\"pip install parallel\" or \"conda install parallel\")."
    exit 1
fi

# Check if column is installed
if ! command -v column &> /dev/null
then
    echo "column could not be found, please install it first."
    exit 1
fi

# Read CORES as the first argument of the command
CORES=$1
if [[ ! $CORES =~ ^[0-9]+$ ]]; then
    echo "The first argument must be the number of cores to use."
    usage
fi
shift  # Remove the core count from the arguments

# Create a temporary directory for chunks
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Determine input source (pipe or file)
if [ -t 0 ]; then
    # No input from pipe, check for file argument
    if [ $# -lt 1 ]; then
        usage
    fi

    # Assume last argument is the file if it exists
    FILE="${!#}"
    if [ ! -f "$FILE" ]; then
        echo "File $FILE does not exist."
        exit 1
    fi

    # Collect remaining arguments as column arguments
    COLUMN_ARGS="$@"

	echo $COLUMN_ARGS
else
    # Input from pipe
    FILE=/dev/stdin
    COLUMN_ARGS="$@"
fi

# Calculate the number of lines in the file
LINE_COUNT=$(wc -l < "$FILE")

# Calculate chunk size based on the number of cores
CHUNKSIZE=$(( (LINE_COUNT + CORES - 1) / CORES ))

# Split the input into chunks
<<<<<<< HEAD
=======
CHUNKSIZE=$CORES
>>>>>>> 3262d954ea1dc04d51c2800136e29a2930c72996
split -l $CHUNKSIZE -d -a 4 --additional-suffix=.chunk "$FILE" "$TMPDIR/chunk_"

# Process each chunk in parallel using the specified number of cores
find "$TMPDIR" -name '*.chunk' | parallel -j $CORES "column $COLUMN_ARGS < {} > {}.out"

<<<<<<< HEAD
# Combine the results and output them in order
cat "$TMPDIR"/*.out
=======
# Combine the results
cat "$TMPDIR"/*.out
>>>>>>> 3262d954ea1dc04d51c2800136e29a2930c72996
