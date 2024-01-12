function __fetch_run_scripts_without_extension
    for file in $run__script_dir/*
        set --local without_extension (string match -r "(.*)\." -- $file)[1]
        echo $without_extension
    end
end

complete -c run -a '(__fetch_run_scripts_without_extension)' --description 'Available scripts'
