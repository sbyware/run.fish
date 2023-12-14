# fish/completions/runscript.fish
function __fish_runscript_script_names
    cat $runscript__history_file
end

function __fish_runscript_complete
    __fish_use_subcommand
    set cmd (commandline -opc)
    set current (commandline -ct)

    switch $cmd
        case "runscript"
            if string match -q -- "--*" $current
                return
            end

            set -l script_names (__fish_runscript_script_names)
            for script in $script_names
                echo $script
            end
        case "*"
            return
    end
end

complete -c runscript -f -a "(__fish_runscript_complete)"
