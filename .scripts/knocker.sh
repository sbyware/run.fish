#!/bin/bash

knock_sequence() {
    local SEQUENCE_NAME="$1"
    local KNOCK_SEQUENCES_FILE=~/.knock_sequences

    # Read knocking sequence for the sequence name from the file
    local KNOCK_SEQUENCE=$(grep "^$SEQUENCE_NAME:" "$KNOCK_SEQUENCES_FILE" | cut -d ':' -f 2)

    if [ -z "$KNOCK_SEQUENCE" ]; then
        echo "Error: Knocking sequence not found in '~/.knock_sequences' for sequence name '$SEQUENCE_NAME'."
        exit 1
    fi

    echo "Knocking for sequence $SEQUENCE_NAME ($KNOCK_SEQUENCE) on $SERVER_IP..."
    knock -v $SERVER_IP $KNOCK_SEQUENCE
    echo "Knocking complete."
}

if [ ! -f ~/.knock_sequences ]; then
    echo "'~/.knock_sequences' not found, creating it..."
    touch ~/.knock_sequences
fi

if [ ! -s ~/.knock_host ]; then
    echo "'~/.knock_host' not found, creating it..."
    touch ~/.knock_host
fi

if [ "$1" == "--list" ]; then
    cat ~/.knock_sequences | cut -d ':' -f 1
    exit 0
fi

if [ "$1" == "--add" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Usage: $0 --add <sequence_name> <sequence>"
        exit 1
    fi

    SEQUENCE_NAME="$2"
    SEQUENCE="$3"
    KNOCK_SEQUENCES_FILE=~/.knock_sequences

    # Check if sequence name already exists
    if grep -q "^$SEQUENCE_NAME:" "$KNOCK_SEQUENCES_FILE"; then
        echo "Error: Sequence name '$SEQUENCE_NAME' already exists in '~/.knock_sequences'."
        exit 1
    fi

    # Add knocking sequence to the file
    echo "$SEQUENCE_NAME:$SEQUENCE" >> "$KNOCK_SEQUENCES_FILE"
    echo "Added knocking sequence '$SEQUENCE_NAME' to '~/.knock_sequences'."
    exit 0
fi

# --remove <sequence_name>
if [ "$1" == "--remove" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 --remove <sequence_name>"
        exit 1
    fi

    SEQUENCE_NAME="$2"
    KNOCK_SEQUENCES_FILE=~/.knock_sequences

    # Check if sequence name exists
    if ! grep -q "^$SEQUENCE_NAME:" "$KNOCK_SEQUENCES_FILE"; then
        echo "Error: Sequence name '$SEQUENCE_NAME' does not exist in '~/.knock_sequences'."
        exit 1
    fi

    # Remove knocking sequence from the file
    sed -i "/^$SEQUENCE_NAME:/d" "$KNOCK_SEQUENCES_FILE"
    echo "Removed knocking sequence '$SEQUENCE_NAME' from '~/.knock_sequences'."
    exit 0
fi

# --set-host <server_ip>
if [ "$1" == "--set-host" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 --set-host <server_ip>"
        exit 1
    fi

    SERVER_IP="$2"
    echo "$SERVER_IP" > ~/.knock_host
    echo "Set server IP to '$SERVER_IP' in '~/.knock_host'."
    exit 0
fi

if [ "$1" == "--edit" ]; then
    $EDITOR ~/.knock_sequences
    exit 0
fi

# if help or no args
if [ "$1" == "--help" ] || [ "$#" -eq 0 ]; then
    echo ""
    echo "Usage: $0 [options] <sequence_name>"
    echo "A simple port knocking script to perform and manage stored knocking sequences for a particular server."
    echo ""
    echo "Options:"
    echo "    --list: List all knocking sequences."
    echo "    --add <sequence_name> <sequence>: Add a knocking sequence."
    echo "    --remove <sequence_name>: Remove a knocking sequence."
    echo "    --edit: Edit the knocking sequences file."
    echo "    --set-host <server_ip>: Set the server IP to knock."
    echo "    --help: Display this help message."
    echo ""
    echo "    <sequence_name>: Knock using the knocking sequence with the given name."
    exit 1
fi

SERVER_IP=$(cat ~/.knock_host)

SEQUENCE_NAME="$1"
knock_sequence "$SEQUENCE_NAME"

exit 0
