#!/bin/bash

KNOCK_SEQUENCES_FILE=~/.knock_sequences
KNOCK_HOST_FILE=~/.knock_host

knock_sequence() {
    local SEQUENCE_NAME="$1"

    # Read knocking sequence for the sequence name from the file
    local KNOCK_SEQUENCE=$(awk -F ':' -v seq_name="$SEQUENCE_NAME" '$1 == seq_name {print $2}' "$KNOCK_SEQUENCES_FILE")

    if [ -z "$KNOCK_SEQUENCE" ]; then
        echo "Error: Knocking sequence not found in '~/.knock_sequences' for sequence name '$SEQUENCE_NAME'."
        exit 1
    fi

    echo "Knocking for sequence $SEQUENCE_NAME ($KNOCK_SEQUENCE) on $SERVER_IP..."
    knock -v "$SERVER_IP" $KNOCK_SEQUENCE
    echo "Knocking complete."
}

initialize_files() {
    touch "$KNOCK_SEQUENCES_FILE" "$KNOCK_HOST_FILE"
}

list_sequences() {
    cut -d ':' -f 1 "$KNOCK_SEQUENCES_FILE"
}

add_sequence() {
    local SEQUENCE_NAME="$1"
    local SEQUENCE="$2"

    if grep -q "^$SEQUENCE_NAME:" "$KNOCK_SEQUENCES_FILE"; then
        echo "Error: Sequence name '$SEQUENCE_NAME' already exists in '~/.knock_sequences'."
        exit 1
    fi

    echo "$SEQUENCE_NAME:$SEQUENCE" >> "$KNOCK_SEQUENCES_FILE"
    echo "Added knocking sequence '$SEQUENCE_NAME' to '~/.knock_sequences'."
}

remove_sequence() {
    local SEQUENCE_NAME="$1"

    if ! grep -q "^$SEQUENCE_NAME:" "$KNOCK_SEQUENCES_FILE"; then
        echo "Error: Sequence name '$SEQUENCE_NAME' does not exist in '~/.knock_sequences'."
        exit 1
    fi

    sed -i "/^$SEQUENCE_NAME:/d" "$KNOCK_SEQUENCES_FILE"
    echo "Removed knocking sequence '$SEQUENCE_NAME' from '~/.knock_sequences'."
}

set_host() {
    local SERVER_IP="$1"
    echo "$SERVER_IP" > "$KNOCK_HOST_FILE"
    echo "Set server IP to '$SERVER_IP' in '~/.knock_host'."
}

edit_sequences() {
    $EDITOR "$KNOCK_SEQUENCES_FILE"
}

print_help() {
    cat <<EOL

Usage: $0 [options] <sequence_name>
A simple port knocking script to perform and manage stored knocking sequences for a particular server.

Options:
    --list: List all knocking sequences.
    --add <sequence_name> <sequence>: Add a knocking sequence.
    --remove <sequence_name>: Remove a knocking sequence.
    --edit: Edit the knocking sequences file.
    --set-host <server_ip>: Set the server IP to knock.
    --help: Display this help message.

    <sequence_name>: Knock using the knocking sequence with the given name.

EOL
    exit 1
}

# Main script starts here

initialize_files

if [ "$1" == "--list" ]; then
    list_sequences
    exit 0
fi

if [ "$1" == "--add" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Usage: $0 --add <sequence_name> <sequence>"
        exit 1
    fi
    add_sequence "$2" "$3"
    exit 0
fi

if [ "$1" == "--remove" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 --remove <sequence_name>"
        exit 1
    fi
    remove_sequence "$2"
    exit 0
fi

if [ "$1" == "--set-host" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 --set-host <server_ip>"
        exit 1
    fi
    set_host "$2"
    exit 0
fi

if [ "$1" == "--edit" ]; then
    edit_sequences
    exit 0
fi

if [ "$1" == "--help" ] || [ "$#" -eq 0 ]; then
    print_help
fi

SERVER_IP=$(cat "$KNOCK_HOST_FILE")

if [ -z "$SERVER_IP" ]; then
    echo "Error: Server IP not set in '~/.knock_host'. Use '$0 --set-host <server_ip>' to set it."
    exit 1
fi

SEQUENCE_NAME="$1"
knock_sequence "$SEQUENCE_NAME"

exit 0
