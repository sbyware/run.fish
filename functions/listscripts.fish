function listscripts
    ls -l $__run_script_dir | awk '{print $9}' | sed '1d' | sed 's/\..*//'
end