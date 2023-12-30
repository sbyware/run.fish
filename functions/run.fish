function run --description "Runs the corresponding script in the $run__script_dir directory"
    set --local script_name $argv[1]
    set --local script_args $argv[2..-1]
    set --local script_path ""

    if test -z $script_name
        echo "[run] Error: No script name provided"
        __print_help
        return 1
    end

    if test $script_name = "--help"
        __print_help
        return 0
    end

    if test $script_name = "--version"
        echo "[run] v$run__version by $run__author ($run__repo_url)"
        return 0
    end

    for extension in $run__allowed_extensions
        if test -f "$run__script_dir/$script_name.$extension"
            set script_path "$run__script_dir/$script_name.$extension"
            break
        end
    end

    if test -z $script_path
        echo "[run] Error: No script found with name $script_name.[$run__allowed_extensions]"
        return 1
    end

    if test ! -x $script_path
        echo "[run] Error: $script_path is not executable"
        return 1
    end

    echo "[run] Running $script_path $script_args..."

    echo "$script_name $script_args" >> $run__history_file

    $script_path $script_args

    echo "[run > $script_name] Done!"

    return 0
end

function run.rm --description "Removes a script in the $run__script_dir directory"
    set --local script_name $argv[1]

    if test (count $argv) -ne 1
        echo "[run.rm] Usage: run.rm <script_name>"
        return 1
    end

    set --local script_path $run__script_dir/$script_name

    for extension in $run__allowed_extensions
        if test -f "$script_path.$extension"
            echo "[run.rm] Deleting $script_path.$extension..."
            rm "$script_path.$extension"
            return 0
        end
    end

    echo "[run.rm] No script found with name $script_name"
    return 1
end

function run.ln --description "Create symbolic link to an existing script in the $run__script_dir directory"
    set --local script_path $argv[1]
    set --local script_full_name (basename $script_path)
    set --local script_name $argv[2]
    set --local script_extension (echo $script_full_name | cut -d'.' -f2)
    set --local valid_extension 1

    if test -z $script_name
        set script_name (echo $script_full_name | cut -d'.' -f1)
    end

    if test (count $argv) -lt 1
        echo "[run.ln] Usage: run.ln <script_path> <script_alias (optional)>"
        return 1
    end

    if test ! -f $script_path
        echo "[run.ln] Error: $script_path does not exist"
        return 1
    end

    if test ! -x $script_path
        echo "[run.ln] Error: $script_path is not executable"
        return 1
    end

    for extension in $run__allowed_extensions
        if test $script_extension = $extension
            set valid_extension 0
            break
        end
    end

    if test $valid_extension -ne 0
        echo "[run.ln] Error: $script_extension is not a valid extension"
        return 1
    end

    if test -f "$run__script_dir/$script_name.$script_extension"
        echo "[run.ln] Error: $run__script_dir/$script_name.$script_extension already exists"
        return 1
    end

    echo "[run.ln] Creating symbolic link '$run__script_dir/$script_name.$script_extension'..."

    ln -s $script_path "$run__script_dir/$script_name.$script_extension"

    echo "[run.ln] Done! Created '$run__script_dir/$script_name.$script_extension'."
end

function run.history --description "Lists the history of scripts run with run"
    cat $run__history_file
end

function run.log --description "Displays the run log file"
    cat $run__log_file
end

function run.ls --description "Lists all scripts in the $run__script_dir directory"
    echo "[run.ls] Scripts in $run__script_dir:"
    for extension in $run__allowed_extensions
        for script in $run__script_dir/*.$extension
            echo "- $(basename $script .$extension)"
        end
    end
end

function run.edit --description "Opens the script in the $run__script_dir directory in $EDITOR"
    if test (count $argv) -ne 1
        echo "[run.edit] Usage: run.edit <script_name>"
        return 1
    end

    set --local script_name $argv[1]
    set --local script_path $run__script_dir/$script_name

    for extension in $run__allowed_extensions
        if test -f "$script_path.$extension"
            echo "[run.edit] Opening $script_path.$extension in $EDITOR..."
            $EDITOR "$script_path.$extension"
            return 0
        end
    end

    echo "[run.edit] No script found with name $script_name"
    return 1
end

function run.new --description "Creates a new script in the $run__script_dir directory"
    set --local script_name $argv[1]
    set --local script_type $argv[2]

    if test (count $argv) -ne 2
        echo "[run.new] Usage: run.new <script_name> <script_type>"
        return 1
    end

    set --local executor_path (which $script_type)

    if test -z "$executor_path"
        echo "[run.new] Couldn't find binary for $script_type"
        return 1
    end

    for executable in $run__allowed_executables
        if test $executor_path = $executable
            break
        end
    end

    if test $executor_path != $executable
        echo "[run.new] Error: $script_type is not an allowed executable"
        return 1
    end

    if test -f "$run__script_dir/$script_name.$script_extension"
        echo "[run.new] $run__script_dir/$script_name.$script_extension already exists"
        return 1
    end

    echo "[run.new] Creating '$run__script_dir/$script_name.$script_extension'..."

    echo "#!$executor_path" > "$run__script_dir/$script_name.$script_extension"
    chmod +x "$run__script_dir/$script_name.$script_extension"

    echo "[run.new] Done! Created '$run__script_dir/$script_name.$script_extension'. Opening in $EDITOR..."

    $EDITOR "$run__script_dir/$script_name.$script_extension"
end

# Private functions

function __log --description "Logs a message to the run log file"
    echo "[$(date)] $argv" >> $run__log_file
end

function __print_help --description "Prints the help message"
    echo "[run] Usage: run [options] <script_name> [...args]"
    echo "    --help: Prints this help message"
    echo "    --version: Prints the version of run"
    echo "Additional commands:"
    echo "  run.rm <script_name>: Deletes a script in the $run__script_dir directory"
    echo "  run.ln <script_path> <script_alias (optional)>: Create symbolic link to an existing script in the $run__script_dir directory"
    echo "  run.new <script_name> <script_type>: Creates a new script in the $run__script_dir directory"
    echo "  run.ls: Lists all scripts in the $run__script_dir directory"
    echo "  run.history: Lists the history of scripts run with run"
    echo "  run.log: Displays the run log file"
    echo "  run.edit <script_name>: Opens the script in the $run__script_dir directory in $EDITOR"
    echo ""
    echo "Examples: run.new test node, run.ln /path/to/script.sh, run.edit test"
end
