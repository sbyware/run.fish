function editscript
    if test (count $argv) -ne 1
        echo "Usage: $argv[0] <script_name>"
        return 1
    end

    set possible_script_extensions sh py js bun.ts fish
    set script_name $argv[1]
    set script_path "$__run_script_dir/$script_name"

    for extension in $__run_script_allowed_extensions
        if test -f "$script_path.$extension"
            echo "Opening $script_path.$extension in $EDITOR..."
            $EDITOR "$script_path.$extension"
            return 0
        end
    end

    echo "No script found with name $script_name"
    return 1
end
