function _runscript_install --on-event runscript_install
    echo "[runscript installer] setting up runscript variables"
    set -gx runscript__allowed_extensions "fish" "js" "bun.ts" "py" "sh"
    set -gx runscript__allowed_executables "fish" "node" "bun" "python3" "bash"
    set -gx runscript__dir "$HOME/.runscript"
    set -gx runscript__history_file "$runscript__dir/.history"
    set -gx runscript__script_dir "$runscript__dir/scripts"
    set -gx runscript__log_file "$runscript__dir/.log"
    set -gx runscript__version "1.0.0"
    set -gx runscript__repo_url "https://github.com/sby051/runscript.fish"
    echo "[runscript installer] installing runscript v$runscript__version"
    echo "[runscript installer] creating runscript directory"
    mkdir -p $runscript__script_dir
    touch $runscript__history_file
    touch $runscript__log_file
    echo "[runscript installer] copying scripts to $runscript__dir"
    cp -r (pwd)"/scripts" $runscript__dir
    echo "[runscript installer] installed runscript v$runscript__version"
end

function _runscript_uninstall --on-event runscript_uninstall
    echo "[runscript uninstaller] uninstalling runscript v$runscript__version"
    echo "[runscript uninstaller] removing runscript directory"
    rm -rf $runscript__dir
    echo "[runscript uninstaller] removing runscript variables"
    set -e runscript__allowed_extensions
    set -e runscript__allowed_executables
    set -e runscript__dir
    set -e runscript__history_file
    set -e runscript__script_dir
    set -e runscript__log_file
    set -e runscript__repo_urls
    echo "[runscript uninstaller] uninstalled runscript v$runscript__version"
    set -e runscript__version
end