function dedup_path
    # Remove duplicate PATH entries
    set -l new_path
    for p in $PATH
        if not contains $p $new_path
            set new_path $new_path $p
        end
    end
    set -gx PATH $new_path
end