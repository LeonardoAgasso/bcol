#!/bin/bash

# Check if parallel is installed
if ! command -v parallel &> /dev/null
then
    echo "parallel could not be found, please install it first."
    exit 1
fi

# Check if column is installed
if ! command -v column &> /dev/null
then
    echo "column could not be found, please install it first."
    exit 1
fi

# Function to display usage information
usage() {
    echo "Usage: $0 [options for column] [file]"
    echo "Options for column are passed directly to the column command."
    exit 1
}

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

    # All arguments except the last one (file)
    COLUMN_ARGS="${@:1:$#-1}"
else
    # Input from pipe
    FILE=/dev/stdin
    COLUMN_ARGS="$@"
fi

# Split the input into chunks
CHUNKSIZE=1000  # You can adjust this size based on your needs
split -l $CHUNKSIZE -d -a 4 --additional-suffix=.chunk "$FILE" "$TMPDIR/chunk_"

# Process each chunk in parallel
find "$TMPDIR" -name '*.chunk' | parallel "column $COLUMN_ARGS < {} > {}.out"

# Combine the results
cat "$TMPDIR"/*.out