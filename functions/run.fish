function run --description "Execute script from the $run__script_dir directory"
    set --local script_name $argv[1]
    set --local script_args $argv[2..-1]
    set --local script_path

    switch $script_name
        case '--help'
            __print_help
            return 0

        case '--version'
            echo "[run] v$run__version by $run__author ($run__repo_url)"
            return 0

        case ''
            echo "[run] Error: No script name provided."
            __print_help
            return 1
    end

    for extension in $run__allowed_extensions
        if test -f "$run__script_dir/$script_name.$extension"
            set script_path "$run__script_dir/$script_name.$extension"
            break
        end
    end

    if test -z $script_path
        echo "[run] Error: Script '$script_name' not found. Valid extensions: $run__allowed_extensions"
        return 1
    end

    if not test -x $script_path
        echo "[run] Error: Script '$script_path' is not executable."
        return 1
    end

    echo "[run] Executing '$script_path' with arguments: $script_args"
    echo "$script_name $script_args" >> $run__history_file
    $script_path $script_args
    echo "[run] '$script_name' execution completed."

    return 0
end

function run.rm --description "Remove a script from the $run__script_dir directory"
    set --local script_name $argv[1]

    if test (count $argv) -ne 1
        echo "[run.rm] Usage: run.rm <script_name>"
        return 1
    end

    for extension in $run__allowed_extensions
        if test -f "$run__script_dir/$script_name.$extension"
            echo "[run.rm] Deleting '$run__script_dir/$script_name.$extension'..."
            rm "$run__script_dir/$script_name.$extension"
            return 0
        end
    end

    echo "[run.rm] Script '$script_name' not found."
    return 1
end

function run.ln --description "Create symbolic link to a script in $run__script_dir"
    if test (count $argv) -lt 1
        echo "[run.ln] Usage: run.ln <script_path> [<script_alias>]"
        return 1
    end

    set --local script_path $argv[1]
    set --local script_name $argv[2]

    if test -z $script_name
        set script_name (basename $script_path .*)
    end

    if not test -f $script_path
        echo "[run.ln] Error: Script '$script_path' does not exist."
        return 1
    end

    if not test -x $script_path
        echo "[run.ln] Error: Script '$script_path' is not executable."
        return 1
    end

    set --local script_extension (string split -r . -- $script_path)[2]
    if not contains $script_extension $run__allowed_extensions
        echo "[run.ln] Error: Extension '$script_extension' is not valid."
        return 1
    end

    if test -f "$run__script_dir/$script_name.$script_extension"
        echo "[run.ln] Error: '$run__script_dir/$script_name.$script_extension' already exists."
        return 1
    end

    set --local absolute_script_path (realpath $script_path)
    ln -s $absolute_script_path "$run__script_dir/$script_name.$script_extension"
    echo "[run.ln] Symbolic link created: '$run__script_dir/$script_name.$script_extension'"

    return 0
end

function run.history --description "List history of executed scripts"
    cat $run__history_file
end

function run.log --description "Display run log file"
    cat $run__log_file
end

function run.ls --description "List scripts in $run__script_dir"
    echo "[run.ls] Scripts in $run__script_dir:"
    for extension in $run__allowed_extensions
        for script in $run__script_dir/*.$extension
            echo "- (basename $script .$extension)"
        end
    end
end

function run.edit --description "Edit a script in $run__script_dir with $EDITOR"
    if test (count $argv) -ne 1
        echo "[run.edit] Usage: run.edit <script_name>"
        return 1
    end

    set --local script_name $argv[1]
    for extension in $run__allowed_extensions
        if test -f "$run__script_dir/$script_name.$extension"
            echo "[run.edit] Opening '$run__script_dir/$script_name.$extension' in $EDITOR"
            eval $EDITOR "$run__script_dir/$script_name.$extension"
            return 0
        end
    end

    echo "[run.edit] Script '$script_name' not found."
    return 1
end

function run.new --description "Create a new script in $run__script_dir"
    if test (count $argv) -ne 2
        echo "[run.new] Usage: run.new <script_name> <script_type>"
        return 1
    end

    set --local script_name $argv[1]
    set --local script_type $argv[2]

    set --local executor_path (command -v $script_type)
    if test -z "$executor_path"
        echo "[run.new] Error: '$script_type' not found."
        return 1
    end

    set --local script_extension (contains -i $script_type $run__allowed_executables)
    if test -z $script_extension
        echo "[run.new] Error: '$script_type' is not a valid type."
        return 1
    end

    set --local script_path "$run__script_dir/$script_name.$script_extension"
    if test -f $script_path
        echo "[run.new] Error: '$script_path' already exists."
        return 1
    end

    echo "#!$executor_path" > $script_path
    chmod +x $script_path
    echo "[run.new] Script '$script_path' created and opened in $EDITOR"
    eval $EDITOR $script_path

    return 0
end

# Private functions

function __log --description "Log a message to the run log file"
    echo "[$(date)] $argv" >> $run__log_file
end

function __print_help --description "Print the help message"
    echo "[run] Usage: run [options] <script_name> [...args]"
    echo "    --help: Prints this help message"
    echo "    --version: Prints the version of run"
    echo "Additional commands:"
    echo "  run.rm <script_name>: Delete a script in $run__script_dir"
    echo "  run.ln <script_path> [<script_alias>]: Create symbolic link to a script in $run__script_dir"
    echo "  run.new <script_name> <script_type>: Create a new script in $run__script_dir"
    echo "  run.ls: List scripts in $run__script_dir"
    echo "  run.history: List history of executed scripts"
    echo "  run.log: Display run log file"
    echo "  run.edit <script_name>: Edit a script in $run__script_dir with $EDITOR"
    echo "Examples: run.new test.sh node, run.ln /path/to/script.sh, run.edit test"
end
