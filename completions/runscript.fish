# fish/completions/run.fish
function __fish_run_script_names
    cat $run__history_file
end

function __fish_run_complete
    __fish_use_subcommand
    set cmd (commandline -opc)
    set current (commandline -ct)

    switch $cmd
        case "run"
            if string match -q -- "--*" $current
                return
            end

            set -l script_names (__fish_run_script_names)
            for script in $script_names
                echo $script
            end
        case "*"
            return
    end
end

complete -c run -f -a "(__fish_run_complete)"
