function __fetch_run_scripts_without_extension
    for file in $run__script_dir/*.*
        set -l script_name (string replace -r "\.($run__allowed_extensions)\$" "" -- (basename $file))
        echo $script_name
    end
end

complete -c run -a '(__fetch_run_scripts_without_extension)' --description 'Available scripts in $run__script_dir'
