function runscript --description "Runs the corresponding script in the $HOME/.scripts directory"
    set script_name $argv[1]
    set script_args $argv[2..-1]

    if test -z $script_name
        echo "[run.fish] Error: No script name provided"
        return 1
    end

    for extension in $__run_script_allowed_extensions
        if test -f $__run_script_dir/$script_name.$extension
            set script_name $script_name.$extension
            break
        end
    end

    if test ! -f $__run_script_dir/$script_name
        echo "[run.fish] Error: No script found at $__run_script_dir/$script_name"
        return 1
    end

    set command "cd $__run_script_dir && ./$script_name $script_args"
    echo "[run.fish] Running $command"
    eval $command
end
