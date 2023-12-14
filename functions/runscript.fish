function runscript --description "Runs the corresponding script in the $runscript__script_dir directory"
    set --local script_name $argv[1]
    set --local script_args $argv[2..-1]
    set --local script_path ""

    if test -z $script_name
        echo "[runscript] Error: No script name provided"
        __print_help
        return 1
    end

    if test $script_name = "--help"
        __print_help
        return 0
    end

    if test $script_name = "--version"
        echo "[runscript] v$runscript__version by $runscript__author ($runscript__repo_url)"
        return 0
    end

    for extension in $runscript__allowed_extensions
        if test -f "$runscript__script_dir/$script_name.$extension"
            set script_path "$runscript__script_dir/$script_name.$extension"
            break
        end
    end

    if test -z $script_path
        echo "[runscript] Error: No script found with name $script_name.[$runscript__allowed_extensions]"
        return 1
    end

    if test ! -x $script_path
        echo "[runscript] Error: $script_path is not executable"
        return 1
    end

    echo "[runscript] Running $script_path $script_args..."

    echo "$script_name $script_args" >> $runscript__history_file

    $script_path $script_args

    echo "[runscript > $script_name] Done!"

    return 0
end

function runscript.delete --description "Deletes a script in the $runscript__script_dir directory"
    set --local script_name $argv[1]

    if test (count $argv) -ne 1
        echo "[runscript-delete] Usage: runscript-delete <script_name>"
        return 1
    end

    set --local script_path $runscript__script_dir/$script_name

    for extension in $runscript__allowed_extensions
        if test -f "$script_path.$extension"
            echo "[runscript-delete] Deleting $script_path.$extension..."
            rm "$script_path.$extension"
            return 0
        end
    end

    echo "[runscript-delete] No script found with name $script_name"
    return 1
end

function runscript.link --description "Create symbolic link to an existing script in the $runscript__script_dir directory"
    set --local script_path $argv[1]
    set --local script_full_name (basename $script_path)
    set --local script_name $argv[2]
    set --local script_extension (echo $script_full_name | cut -d'.' -f2)
    set --local valid_extension 1

    if test -z $script_name
        set script_name (echo $script_full_name | cut -d'.' -f1)
    end

    if test (count $argv) -lt 1
        echo "[runscript-link] Usage: runscript-link <script_path> <script_alias (optional)>"
        return 1
    end

    if test ! -f $script_path
        echo "[runscript-link] Error: $script_path does not exist"
        return 1
    end

    if test ! -x $script_path
        echo "[runscript-link] Error: $script_path is not executable"
        return 1
    end

    for extension in $runscript__allowed_extensions
        if test $script_extension = $extension
            set valid_extension 0
            break
        end
    end

    if test $valid_extension -ne 0
        echo "[runscript-link] Error: $script_extension is not a valid extension"
        return 1
    end

    if test -f "$runscript__script_dir/$script_name.$script_extension"
        echo "[runscript-link] Error: $runscript__script_dir/$script_name.$script_extension already exists"
        return 1
    end

    echo "[runscript-link] Creating symbolic link '$runscript__script_dir/$script_name.$script_extension'..."

    ln -s $script_path "$runscript__script_dir/$script_name.$script_extension"

    echo "[runscript-link] Done! Created '$runscript__script_dir/$script_name.$script_extension'."
end

function runscript.history --description "Lists the history of scripts run with runscript"
    cat $runscript__history_file
end

function runscript.log --description "Displays the runscript log file"
    cat $runscript__log_file
end

function runscript.list --description "Lists all scripts in the $runscript__script_dir directory"
    echo "[runscript-list] Scripts in $runscript__script_dir:"
    for extension in $runscript__allowed_extensions
        for script in $runscript__script_dir/*.$extension
            echo "- $(basename $script .$extension)"
        end
    end
end

function runscript.edit --description "Opens the script in the $runscript__script_dir directory in $EDITOR"
    if test (count $argv) -ne 1
        echo "[runscript-edit] Usage: runscript-edit <script_name>"
        return 1
    end

    set --local script_name $argv[1]
    set --local script_path $runscript__script_dir/$script_name

    for extension in $runscript__allowed_extensions
        if test -f "$script_path.$extension"
            echo "[runscript-edit] Opening $script_path.$extension in $EDITOR..."
            $EDITOR "$script_path.$extension"
            return 0
        end
    end

    echo "[runscript-edit] No script found with name $script_name"
    return 1
end

function runscript.create --description "Creates a new script in the $runscript__script_dir directory"
    set --local script_name $argv[1]
    set --local script_type $argv[2]

    if test (count $argv) -ne 2
        echo "[runscript-create] Usage: runscript-create <script_name> <script_type>"
        return 1
    end

    set --local executor_path (which $script_type)

    if test -z "$executor_path"
        echo "[runscript-create] Couldn't find binary for $script_type"
        return 1
    end

    for executable in $runscript__allowed_executables
        if test $executor_path = $executable
            break
        end
    end

    if test $executor_path != $executable
        echo "[runscript-create] Error: $script_type is not an allowed executable"
        return 1
    end

    if test -f "$runscript__script_dir/$script_name.$script_extension"
        echo "[runscript-create] $runscript__script_dir/$script_name.$script_extension already exists"
        return 1
    end

    echo "[runscript-create] Creating '$runscript__script_dir/$script_name.$script_extension'..."

    echo "#!$executor_path" > "$runscript__script_dir/$script_name.$script_extension"
    chmod +x "$runscript__script_dir/$script_name.$script_extension"

    echo "[runscript-create] Done! Created '$runscript__script_dir/$script_name.$script_extension'. Opening in $EDITOR..."

    $EDITOR "$runscript__script_dir/$script_name.$script_extension"
end

# Private functions

function __log --description "Logs a message to the runscript log file"
    echo "[$(date)] $argv" >> $runscript__log_file
end

function __print_help --description "Prints the help message"
    echo "[runscript] Usage: runscript [options] <script_name> [...args]"
    echo "    --help: Prints this help message"
    echo "    --version: Prints the version of runscript"
    echo "Additional commands:"
    echo "  runscript.delete <script_name>: Deletes a script in the $runscript__script_dir directory"
    echo "  runscript.link <script_path> <script_alias (optional)>: Create symbolic link to an existing script in the $runscript__script_dir directory"
    echo "  runscript.history: Lists the history of scripts run with runscript"
    echo "  runscript.log: Displays the runscript log file"
    echo "  runscript.list: Lists all scripts in the $runscript__script_dir directory"
    echo "  runscript.edit <script_name>: Opens the script in the $runscript__script_dir directory in $EDITOR"
    echo "  runscript.create <script_name> <script_type>: Creates a new script in the $runscript__script_dir directory"
    echo ""
    echo "Examples: runscript.create test node, runscript.link /path/to/script.sh, runscript.edit test"
end
