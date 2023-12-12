function newscript --description 'Creates a new script to be ran with runscript'
    set script_name $argv[1]
    set script_type $argv[2]
    set script_extension "unknown"
    set executor_path "unknown"

    if test -z "$script_name"
        echo "[$0] Please provide a script name"
        return 1
    end

    if test -z "$script_type"
        echo "[$0] Please provide a script type"
        return 1
    end

    if test "$script_type" = "bash"
        set executor_path (command which bash)
        set script_extension "sh"
    else if test "$script_type" = "python"
        set executor_path (command which python)
        set script_extension "py"
    else if test "$script_type" = "node"
        set executor_path (command which node)
        set script_extension "js"
    else if test "$script_type" = "bun"
        set executor_path (command which bun)
        set script_extension "bun.ts"
    else if test "$script_type" = "fish"
        set executor_path (command which fish)
        set script_extension "fish"
    else
        echo "[$0] Unknown script type $script_type"
        return 1
    end

    if test -z "$executor_path"
        echo "[$0] Couldn't find binary for $script_type"
        return 1
    end

    if test -f "$__run_script_dir/$script_name.$script_extension"
        echo "[$0] $__run_script_dir/$script_name.$script_extension already exists"
        return 1
    end

    echo "[$0] Creating '$__run_script_dir/$script_name.$script_extension'..."

    echo "#!$executor_path" > "$__run_script_dir/$script_name.$script_extension"
    chmod +x "$__run_script_dir/$script_name.$script_extension"

    if test "$script_type" = "bash"
        echo 'echo "[$0] Hello world"' >> "$__run_script_dir/$script_name.$script_extension"
    else if test "$script_type" = "python"
        echo 'print("[$0] Hello world")' >> "$__run_script_dir/$script_name.$script_extension"
    else if test "$script_type" = "node"
        echo 'console.log("[$0] Hello world")' >> "$__run_script_dir/$script_name.$script_extension"
    else if test "$script_type" = "bun"
        echo 'console.log("[$0] Hello world" as string)' >> "$__run_script_dir/$script_name.$script_extension"
    else if test "$script_type" = "fish"
        echo 'echo "[$0] Hello world"' >> "$__run_script_dir/$script_name.$script_extension"
    else
        echo "[$0] Unknown script type $script_type"
        return 1
    end

    echo "[$0] Done! Created '$__run_script_dir/$script_name.$script_extension'. Opening in $EDITOR..."

    $EDITOR "$__run_script_dir/$script_name.$script_extension"
end
