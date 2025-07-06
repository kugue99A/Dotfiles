function vf
    fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim
end
