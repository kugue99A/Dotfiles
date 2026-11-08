{ config, pkgs, ... }:

let
  statusPython = pkgs.python3.withPackages (p: [ p.psutil ]);
in
{
  # === ヘルパースクリプト ===

  # 1. アプリ名→アイコン マッピング (sketchybar-app-font 公式版)
  home.file.".config/sketchybar/helpers/icon_map.sh" = {
    source = "${pkgs.sketchybar-app-font}/bin/icon_map.sh";
    executable = true;
  };

  # One persistent worker consumes AeroSpace socket events and batches updates.
  home.file.".config/sketchybar/helpers/status_daemon.py".source = ./sketchybar/status_daemon.py;
  home.file."Library/Logs/sketchybar/.keep".text = "";
  launchd.agents.sketchybar-status = {
    enable = true;
    config = {
      ProgramArguments = [ "${statusPython}/bin/python3" "-u" "${./sketchybar/status_daemon.py}" ];
      EnvironmentVariables = {
        USER = config.home.username;
        SKETCHYBAR_BINARY = "${pkgs.sketchybar}/bin/sketchybar";
      };
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/sketchybar/status.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/sketchybar/status.err.log";
    };
  };

  # 5. フロントアプリアイコン更新スクリプト
  home.file.".config/sketchybar/helpers/front_app_icon.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      source "$HOME/.config/sketchybar/helpers/icon_map.sh"
      __icon_map "$INFO"
      sketchybar --set "$NAME" icon="$icon_result" label="$INFO"
    '';
  };

  # === SketchyBar 本体設定 ===
  programs.sketchybar = {
    enable = true;
    configType = "bash";
    extraPackages = with pkgs; [ jq ];
    config = ''
      THEME_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme"
      THEME_MODE=dark
      if [[ -r "$THEME_FILE" ]]; then
        IFS= read -r THEME_MODE < "$THEME_FILE"
      fi

      TRANSPARENT=0x00000000
      if [[ "$THEME_MODE" == light ]]; then
        # Ashes Light: subdued colors tuned for the bright translucent desktop.
        BG=0xfff5f4f4
        TEXT=0xff555b60
        INACTIVE=0xff92999d
        HIGHLIGHT=0xfffaf8f7
        ACTIVE_SPACE=0xff8d769d
        CLR_RED=0xffad6e78
        CLR_ORANGE=0xffaa805f
        CLR_YELLOW=0xff8e8355
        CLR_GREEN=0xff52735f
        CLR_AQUA=0xff648b8e
        CLR_BLUE=0xff637c8d
        CLR_PURPLE=0xff856d94
        CLR_BLUE_BR=0xff718ba3
        CLR_PURPLE_BR=0xff987fa1
      else
        # Existing Iceberg Dark palette.
        BG=0xff161821
        TEXT=0xffc6c8d1
        INACTIVE=0xff6b7089
        HIGHLIGHT=0xffd2d4de
        ACTIVE_SPACE=0xffa093c7
        CLR_RED=0xffe27878
        CLR_ORANGE=0xffe2a478
        CLR_YELLOW=0xffe9b189
        CLR_GREEN=0xffb4be82
        CLR_AQUA=0xff89b8c2
        CLR_BLUE=0xff84a0c6
        CLR_PURPLE=0xffa093c7
        CLR_BLUE_BR=0xff91acd1
        CLR_PURPLE_BR=0xffada0d3
      fi

      # Workspace colors; the focused workspace uses a consistent Ashes accent.
      CMAP=($CLR_RED $CLR_ORANGE $CLR_YELLOW $CLR_GREEN $CLR_AQUA $CLR_BLUE $CLR_PURPLE $CLR_BLUE_BR $CLR_PURPLE_BR)

      # === バー全体 (完全透過 + ブラー) ===
      sketchybar --bar \
        height=32 \
        position=top \
        color=$TRANSPARENT \
        border_width=0 \
        padding_left=12 \
        padding_right=12 \
        margin=4 \
        y_offset=4 \
        corner_radius=0 \
        blur_radius=30 \
        sticky=on \
        topmost=off

      # === デフォルト ===
      sketchybar --default \
        icon.font="SauceCodePro Nerd Font Mono:Bold:14.0" \
        icon.color=$TEXT \
        icon.padding_left=8 \
        icon.padding_right=4 \
        label.font="SauceCodePro Nerd Font Mono:Medium:13.0" \
        label.color=$TEXT \
        label.padding_right=8 \
        background.drawing=off \
        padding_left=0 \
        padding_right=0

      # ============================================================
      #  LEFT: ワークスペース
      # ============================================================
      for i in {1..9}; do
        COLOR=''${CMAP[$((i-1))]}
        SPACE_BG=$COLOR
        if [[ "$THEME_MODE" == light ]]; then
          SPACE_BG=$ACTIVE_SPACE
        fi
        sketchybar --add item space.$i left \
                   --set space.$i \
                     icon="$i" \
                     icon.font="SauceCodePro Nerd Font Mono:Bold:14.0" \
                     icon.color=$COLOR \
                     icon.padding_left=8 \
                     icon.padding_right=4 \
                     label.font="sketchybar-app-font:Regular:16.0" \
                     label.color=$COLOR \
                     label.drawing=off \
                     background.color=$SPACE_BG \
                     background.corner_radius=6 \
                     background.height=26 \
                     background.drawing=off \
                     update_freq=0
      done

      # ============================================================
      #  CENTER: フロントアプリ名 (アイコン付き)
      # ============================================================
      sketchybar --add item front_app center \
                 --set front_app \
                   icon.drawing=on \
                   icon.font="sketchybar-app-font:Regular:16.0" \
                   icon.color=$TEXT \
                   icon.padding_right=6 \
                   label.font="SauceCodePro Nerd Font Mono:Bold:13.0" \
                   label.color=$TEXT \
                   background.drawing=off \
                   script='$HOME/.config/sketchybar/helpers/front_app_icon.sh' \
                 --subscribe front_app front_app_switched

      # ============================================================
      #  RIGHT: ウィジェット (追加順 = 右端から左へ)
      # ============================================================

      # --- カレンダー (blue) ---
      sketchybar --add item cal.time right \
                 --set cal.time \
                   icon=󰥔 \
                   icon.color=$CLR_BLUE \
                   label.color=$CLR_BLUE \
                   update_freq=0

      sketchybar --add item cal.date right \
                 --set cal.date \
                   icon.drawing=off \
                   label.padding_left=8 \
                   label.color=$CLR_BLUE \
                   update_freq=0

      sketchybar --add bracket bracket.cal cal.time cal.date \
                 --set bracket.cal \
                   background.color=$TRANSPARENT \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_BLUE

      sketchybar --add item padding.cal right --set padding.cal width=6

      # --- バッテリー (orange) ---
      sketchybar --add item battery right \
                 --set battery \
                   icon.color=$CLR_ORANGE \
                   label.color=$CLR_ORANGE \
                   update_freq=0

      sketchybar --add bracket bracket.battery battery \
                 --set bracket.battery \
                   background.color=$TRANSPARENT \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_ORANGE

      sketchybar --add item padding.battery right --set padding.battery width=6

      # --- 音量 (green) ---
      sketchybar --add item volume right \
                 --set volume \
                   icon.color=$CLR_GREEN \
                   label.color=$CLR_GREEN \
                   script='
                     VOLUME="''${INFO%.*}"
                     case "$VOLUME" in ""|*[!0-9]*) exit 0 ;; esac
                     if [ "$VOLUME" -eq 0 ]; then
                       ICON="󰖁"
                     elif [ "$VOLUME" -le 30 ]; then
                       ICON="󰕿"
                     elif [ "$VOLUME" -le 60 ]; then
                       ICON="󰖀"
                     else
                       ICON="󰕾"
                     fi
                     sketchybar --set $NAME icon="$ICON" label="''${VOLUME}%"
                   ' \
                 --subscribe volume volume_change

      sketchybar --add bracket bracket.volume volume \
                 --set bracket.volume \
                   background.color=$TRANSPARENT \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_GREEN

      sketchybar --add item padding.volume right --set padding.volume width=6

      # --- ネットワーク (purple) ---
      # airport コマンドは macOS Sonoma 以降削除、SSID もプライバシー保護でマスクされるため
      # アクティブインターフェースの IP アドレスを表示する
      sketchybar --add item network right \
                 --set network \
                   icon.color=$CLR_PURPLE \
                   label.color=$CLR_PURPLE \
                   update_freq=0

      sketchybar --add bracket bracket.network network \
                 --set bracket.network \
                   background.color=$TRANSPARENT \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_PURPLE

      sketchybar --add item padding.network right --set padding.network width=6

      # --- メモリ (red) ---
      sketchybar --add item mem right \
                 --set mem \
                   icon=󰍛 \
                   icon.color=$CLR_RED \
                   label.color=$CLR_RED \
                   update_freq=0

      sketchybar --add bracket bracket.mem mem \
                 --set bracket.mem \
                   background.color=$TRANSPARENT \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_RED

      sketchybar --add item padding.mem right --set padding.mem width=6

      # --- CPU グラフ (aqua) ---
      sketchybar --add graph cpu right 100 \
                 --set cpu \
                   icon=󰻠 \
                   icon.color=$CLR_AQUA \
                   label.color=$CLR_AQUA \
                   graph.color=$CLR_AQUA \
                   graph.fill_color=$TRANSPARENT \
                   background.height=20 \
                   background.drawing=on \
                   background.color=$TRANSPARENT \
                   label.y_offset=-4 \
                   icon.y_offset=-4 \
                   y_offset=4 \
                   update_freq=0

      sketchybar --add bracket bracket.cpu cpu \
                 --set bracket.cpu \
                   background.color=$TRANSPARENT \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_AQUA

      # === 初期化完了 ===
      sketchybar --update
    '';
  };
}
