function __fetch_run_scripts_without_extension
    for fileName in $run__script_dir/*
        set -l nameParts (string split "." (basename $fileName))
        set -e nameParts[-1]
        echo (string join "." $nameParts)
    end
end

complete -c run -a '(__fetch_run_scripts_without_extension)' --description 'Available scripts'
