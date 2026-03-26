{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    prefix = "C-q";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 10000;
    keyMode = "vi";
    customPaneNavigationAndResize = false;

    extraConfig = ''
      # ============================================================
      # Zellij互換キーマップ
      # Prefix: Ctrl+q (Zellijと同じ)
      # ============================================================

      # --- 基本設定 ---
      set -g pane-base-index 1
      set -g renumber-windows on
      set -g focus-events on
      set -g set-clipboard on

      # True color support
      set -ga terminal-overrides ",xterm-256color:Tc"

      # --- Prefix mode キーバインド (Zellijのtmuxモードに対応) ---

      # ペイン移動 (vim keys)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ペインリサイズ (大文字vim keys)
      bind H resize-pane -L 5
      bind J resize-pane -D 5
      bind K resize-pane -U 5
      bind L resize-pane -R 5

      # ペイン分割 (Zellijと同じ: s=横, v=縦)
      bind s split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"

      # ウィンドウ(タブ)移動
      bind p previous-window
      bind n next-window

      # ペイン/ウィンドウ削除
      bind x kill-pane
      bind X kill-window

      # 新しいウィンドウ(タブ)
      bind c new-window -c "#{pane_current_path}"

      # コピーモード (Zellijの [ と同じ)
      bind [ copy-mode

      # ペインズーム (Zellijの z と同じ)
      bind z resize-pane -Z

      # デタッチ
      bind d detach-client

      # ウィンドウリネーム
      bind r command-prompt -I "#W" "rename-window '%%'"

      # ウィンドウ番号ジャンプ (1-9)
      bind 1 select-window -t :1
      bind 2 select-window -t :2
      bind 3 select-window -t :3
      bind 4 select-window -t :4
      bind 5 select-window -t :5
      bind 6 select-window -t :6
      bind 7 select-window -t :7
      bind 8 select-window -t :8
      bind 9 select-window -t :9

      # --- Alt キーバインド (Zellijのグローバルショートカットに対応) ---

      # ペイン移動: Alt+hjkl
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # ウィンドウ移動: Alt+n/p
      bind -n M-n next-window
      bind -n M-p previous-window

      # ペイン分割: Alt+v(縦) Alt+s(横)
      bind -n M-v split-window -h -c "#{pane_current_path}"
      bind -n M-s split-window -v -c "#{pane_current_path}"

      # ペインリサイズ: Alt+HJKL
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 5
      bind -n M-K resize-pane -U 5
      bind -n M-L resize-pane -R 5

      # 新しいウィンドウ: Alt+c
      bind -n M-c new-window -c "#{pane_current_path}"

      # ウィンドウ削除: Alt+X / ペイン削除: Alt+x
      bind -n M-X kill-window
      bind -n M-x kill-pane

      # --- コピーモード (vi) (Zellijのscrollモードに対応) ---
      bind -T copy-mode-vi j send-keys -X cursor-down
      bind -T copy-mode-vi k send-keys -X cursor-up
      bind -T copy-mode-vi h send-keys -X cursor-left
      bind -T copy-mode-vi l send-keys -X cursor-right
      bind -T copy-mode-vi d send-keys -X halfpage-down
      bind -T copy-mode-vi u send-keys -X halfpage-up
      bind -T copy-mode-vi C-b send-keys -X page-up
      bind -T copy-mode-vi C-f send-keys -X page-down
      bind -T copy-mode-vi g send-keys -X history-top
      bind -T copy-mode-vi G send-keys -X history-bottom
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi q send-keys -X cancel
      bind -T copy-mode-vi Escape send-keys -X cancel
      bind -T copy-mode-vi / command-prompt -i -p "(search down)" "send -X search-forward-incremental \"%%%\""

      # --- テーマ (Iceberg Dark - Zellijと同じ) ---
      set -g status-style "bg=#161821,fg=#c6c8d1"
      set -g status-left-length 30
      set -g status-right-length 50
      set -g status-left "#[bg=#84a0c6,fg=#161821,bold] #S #[default] "
      set -g status-right "#[fg=#6b7089] %Y-%m-%d %H:%M "
      set -g window-status-format "#[fg=#6b7089] #I:#W "
      set -g window-status-current-format "#[bg=#89b8c2,fg=#161821,bold] #I:#W "
      set -g pane-border-style "fg=#6b7089"
      set -g pane-active-border-style "fg=#84a0c6"
      set -g message-style "bg=#161821,fg=#c6c8d1"
      set -g mode-style "bg=#84a0c6,fg=#161821"
    '';
  };
}
