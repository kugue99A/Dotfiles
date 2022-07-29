function _tide_init_install --on-event _tide_init_install
    set -U tide_os_icon (_tide_detect_os)
    set -U VIRTUAL_ENV_DISABLE_PROMPT true
    set -U _tide_var_list tide_os_icon VIRTUAL_ENV_DISABLE_PROMPT

    source (functions --details _tide_sub_configure)
    _load_config lean
    _tide_finish
    set -a _tide_var_list (set --names | string match --regex "^tide.*")

    status is-interactive && switch (read --prompt-str="Configure tide prompt? [Y/n] " | string lower)
        case y ye yes ''
            tide configure
        case '*'
            printf '%s' \n 'Run ' (printf '%s' "tide configure" | fish_indent --ansi) ' to customize your prompt.' \n
    end
end

function _tide_init_update --on-event _tide_init_update
    # v5 introduced tide_prompt_min_cols. Only proceed if older than v5
    set --query tide_prompt_min_cols && return

    # Save old vars to tmp file
    set -l tmp (mktemp -t tide_old_config.XXXXX)
    tide bug-report --verbose >$tmp

    # Delete old vars
    set -e $_tide_var_list _tide_var_list $_tide_prompt_var

    # Print a warning
    set_color yellow
    echo "You have upgraded to version 5 of Tide."
    echo "Since there are breaking changes, your old configuraton has been saved in:"
    set_color normal
    echo $tmp

    sleep 5

    _tide_init_install
end

function _tide_init_uninstall --on-event _tide_init_uninstall
    set -e $_tide_var_list _tide_var_list $_tide_prompt_var
    functions --erase (functions --all | string match --entire --regex '^_tide_')
end

set -g tide_prompt_color_frame_and_connection ebdbb2
set -g tide_prompt_color_separator_same_color ebdbb2
set -g tide_left_prompt_separator_diff_color 
set -g tide_cmd_duration_bg_color 458588
set -g tide_cmd_duration_color ebdbb2
set -g tide_character_bg_color 458588
set -g tide_character_color 458588
set -g tide_status_bg_color 458588
set -g tide_status_color ebdbb2
set -g tide_status_bg_color_failure fb4934
set -g tide_status_color_failure ebdbb2
set -g tide_jobs_bg_color 458588
set -g tide_jobs_color ebdbb2
set -g tide_os_bg_color 458588
set -g tide_os_color ebdbb2
set -g tide_git_bg_color 458588
set -g tide_git_bg_color_unstable d79921
set -g tide_git_bg_color_urgent CC0000
set -g tide_git_branch_color ebdbb2
set -g tide_git_color_branch ebdbb2
set -g tide_git_color_conflicted ebdbb2
set -g tide_git_color_dirty d65d0e
set -g tide_git_color_operation ebdbb2
set -g tide_git_color_staged ebdbb2
set -g tide_git_color_stash ebdbb2
set -g tide_git_color_untracked 504945
set -g tide_git_color_upstream 458588
set -g tide_git_conflicted_color ebdbb2
set -g tide_git_icon 
set -g tide_git_operation_color ebdbb2
set -g tide_git_staged_color ebdbb2
set -g tide_git_stash_color ebdbb2
set -g tide_git_untracked_color ebdbb2
set -g tide_git_upstream_color ebdbb2
set -g tide_pwd_bg_color 504945
set -g tide_pwd_color_anchors 83a598
set -g tide_pwd_color_dirs ebdbb2
