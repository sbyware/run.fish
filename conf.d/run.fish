set -gx run__allowed_extensions "fish" "js" "bun.ts" "py" "sh"
set -gx run__allowed_executables "fish" "node" "bun" "python3" "bash"
set -gx run__dir "$HOME/.run"
set -gx run__history_file "$run__dir/.history"
set -gx run__script_dir "$run__dir/scripts"
set -gx run__log_file "$run__dir/.log"
set -gx run__version "1.0.0"
set -gx run__repo_url "https://github.com/sby051/run.fish"

function _run_install --on-event run_install
    echo "[run.fish installer] installing run v$run__version"
    echo "[run.fish installer] creating run directory"
    mkdir -p $run__script_dir
    touch $run__history_file
    touch $run__log_file
    echo "[run.fish installer] copying scripts to $run__dir"
    cp -r (pwd)"/scripts" $run__dir
    echo "[run.fish installer] installed run v$run__version"
end

function _run_uninstall --on-event run_uninstall
    echo "[run.fish uninstaller] uninstalling run v$run__version"
    echo "[run.fish uninstaller] would you like to keep your scripts? [Y/n]: "
    read keep_scripts
    if test $keep_scripts = "n"
        echo "[run.fish uninstaller] removing scripts"
        rm -rf $run__dir
    end
    echo "[run.fish uninstaller] removing run variables"
    set -e run__allowed_extensions
    set -e run__allowed_executables
    set -e run__dir
    set -e run__history_file
    set -e run__script_dir
    set -e run__log_file
    set -e run__repo_urls
    echo "[run.fish uninstaller] uninstalled run v$run__version"
    set -e run__version
end