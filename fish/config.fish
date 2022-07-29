alias vim 'nvim'

# cargo
set -gx PATH $HOME/.cargo/bin $PATH

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
set -g fish_user_paths $PYENV_ROOT/bin $fish_user_paths
status is-login; and pyenv init --path | source
pyenv init - | source

#goenv
set -x GOENV_ROOT $HOME/.goenv
set -x PATH $GOENV_ROOT/bin $PATH
. (goenv init - | source)
set -x PATH $GOPATH/bin $PATH

# color
set fish_color_normal         EBDBB2 
set fish_color_autosuggestion A89984
set fish_color_cancel         brcyan
set fish_color_command        83A598
set fish_color_comment        EBDBB2
set fish_color_cwd            D3869B 
set fish_color_end            brwhite
set fish_color_error          fb4934 
set fish_color_escape         brcyan
set fish_color_host           brgreen
set fish_color_host_remote    bryellow
set fish_color_match          brcyan --underline
set fish_color_operator       brpurple
set fish_color_param          D3869B
set fish_color_quote          brgreen
set fish_color_redirection    brcyan
set fish_color_search_match   --background=689D6A
set fish_color_selection      --background=689D6A
set fish_color_user           689d69

# cd + ls
function cd
  builtin cd $argv[1]
  ls
end

#rbenv
set -x PATH $HOME/.rbenv/bin $PATH
status --is-interactive; and source (rbenv init -|psub)

#dir color
export LSCOLORS=gxfxcxdxbxegedabagacad

set fish_plugins theme peco

function fish_user_key_bindings
  bind \^r peco_select_history # Bind for prco history to Ctrl+r
end

alias ls 'exa'
alias la 'exa -l'
alias restart-docker 'killall Docker && open /Applications/Docker.app'

set -x PATH $HOME/fvm/default/bin $PATH

# GrADS
set -x PATH /Applications/OpenGrADS $PATH

