function __fetch_run_scripts
    set -l scripts (string replace -r "\.($run__allowed_extensions)\$" "" -- (basename -a $run__script_dir/*))
    for script in $scripts
        echo $script
    end
end

complete -c run -a '(__fetch_run_scripts)' --description 'Available scripts'