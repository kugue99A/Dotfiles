{ pkgs, ... }:

{
  # === ヘルパースクリプト ===

  # 1. アプリ名→NerdFontアイコン マッピング
  home.file.".config/sketchybar/helpers/icon_map.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # アプリ名→NerdFont アイコンマッピング
      # 使い方: source icon_map.sh; __icon_map "AppName"; echo $icon_result

      __icon_map() {
        case "$1" in
          # ブラウザ
          "Safari"|"safari")                   icon_result="󰀹" ;;
          "Google Chrome"|"Chrome")            icon_result="" ;;
          "Arc")                               icon_result="󰞍" ;;
          "Firefox"|"firefox")                 icon_result="󰈹" ;;
          "Brave Browser")                     icon_result="󰖟" ;;
          "Microsoft Edge")                    icon_result="󰇩" ;;
          "Orion")                             icon_result="󰇧" ;;
          # ターミナル・エディタ
          "WezTerm"|"wezterm-gui")             icon_result="" ;;
          "Terminal"|"ターミナル")             icon_result="" ;;
          "iTerm2"|"iTerm")                    icon_result="" ;;
          "Alacritty")                         icon_result="" ;;
          "kitty")                             icon_result="󰄛" ;;
          "Code"|"Visual Studio Code")         icon_result="󰨞" ;;
          "Cursor")                            icon_result="󰨞" ;;
          "Neovide")                           icon_result="" ;;
          "Zed")                               icon_result="󰘦" ;;
          "Xcode")                             icon_result="󰘦" ;;
          "IntelliJ IDEA"*)                    icon_result="" ;;
          # コミュニケーション
          "Slack")                             icon_result="󰒱" ;;
          "Discord")                           icon_result="󰙯" ;;
          "Microsoft Teams"*)                  icon_result="󰊻" ;;
          "Telegram")                          icon_result="" ;;
          "LINE")                              icon_result="󰍡" ;;
          "Messages"|"メッセージ")             icon_result="󰍦" ;;
          "Mail"|"メール")                     icon_result="󰇮" ;;
          "Thunderbird")                       icon_result="" ;;
          # メディア
          "Spotify")                           icon_result="󰓇" ;;
          "Music"|"ミュージック")              icon_result="󰝚" ;;
          "YouTube Music")                     icon_result="󰗃" ;;
          "VLC"|"IINA")                        icon_result="󰕼" ;;
          "Photos"|"写真")                     icon_result="󰋩" ;;
          "Preview"|"プレビュー")              icon_result="" ;;
          # Apple
          "Finder")                            icon_result="󰀶" ;;
          "System Preferences"|"System Settings"|"システム設定") icon_result="" ;;
          "App Store")                         icon_result="" ;;
          "Activity Monitor"|"アクティビティモニタ") icon_result="󱕍" ;;
          "Calendar"|"カレンダー")             icon_result="" ;;
          "Notes"|"メモ")                      icon_result="󱞎" ;;
          "Reminders"|"リマインダー")          icon_result="󰃮" ;;
          "FaceTime")                          icon_result="" ;;
          "Maps"|"マップ")                     icon_result="󰍎" ;;
          "Keychain Access"|"キーチェーンアクセス") icon_result="" ;;
          # 開発ツール
          "Docker"|"Docker Desktop")           icon_result="" ;;
          "Postman")                           icon_result="󰒍" ;;
          "TablePlus")                         icon_result="󰆼" ;;
          "GitKraken")                         icon_result="" ;;
          # デザイン
          "Figma")                             icon_result="" ;;
          "Sketch")                            icon_result="" ;;
          "Affinity Designer"*)                icon_result="󰃣" ;;
          "Affinity Photo"*)                   icon_result="󰃣" ;;
          # ユーティリティ
          "1Password"*)                        icon_result="󰌋" ;;
          "Raycast")                           icon_result="󰑣" ;;
          "Alfred")                            icon_result="" ;;
          "Notion")                            icon_result="󰈄" ;;
          "Obsidian")                          icon_result="󱓧" ;;
          "Karabiner-Elements"*)               icon_result="󰌌" ;;
          "Parallels Desktop")                 icon_result="󰒋" ;;
          "Transmit")                          icon_result="󰒍" ;;
          # PDF・オフィス
          "Microsoft Word")                    icon_result="󰈬" ;;
          "Microsoft Excel")                   icon_result="󰈛" ;;
          "Microsoft PowerPoint")              icon_result="󰈧" ;;
          "Pages")                             icon_result="󰈙" ;;
          "Numbers")                           icon_result="󰈛" ;;
          "Keynote")                           icon_result="󰐨" ;;
          "Adobe Acrobat"*)                    icon_result="" ;;
          # フォールバック: 先頭1文字
          *)                                   icon_result="''${1:0:1}" ;;
        esac
      }
    '';
  };

  # 2. ワークスペースアイコン更新スクリプト
  home.file.".config/sketchybar/helpers/workspace_icons.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # 使い方: workspace_icons.sh <workspace_id>
      WORKSPACE="$1"
      [ -z "$WORKSPACE" ] && exit 1

      source "$HOME/.config/sketchybar/helpers/icon_map.sh"

      APPS="$(${pkgs.aerospace}/bin/aerospace list-windows --workspace "$WORKSPACE" --format '%{app-name}' 2>/dev/null)"

      ICON_STRIP=""
      if [ -n "$APPS" ]; then
        while IFS= read -r APP; do
          __icon_map "$APP"
          ICON_STRIP+=" $icon_result"
        done <<< "$APPS"
      fi

      if [ -n "$ICON_STRIP" ]; then
        sketchybar --set "space.$WORKSPACE" label="$ICON_STRIP" label.drawing=on
      else
        sketchybar --set "space.$WORKSPACE" label.drawing=off
      fi
    '';
  };

  # 3. フロントアプリアイコン更新スクリプト
  home.file.".config/sketchybar/helpers/front_app_icon.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      source "$HOME/.config/sketchybar/helpers/icon_map.sh"
      __icon_map "$INFO"
      sketchybar --set "$NAME" icon="$icon_result" label="$INFO"
    '';
  };

  # 4. CPU更新スクリプト
  home.file.".config/sketchybar/helpers/cpu_update.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      NCPU=$(sysctl -n hw.ncpu)
      CPU_PCT=$(ps -A -o %cpu= | awk -v n="$NCPU" '{s+=$1} END {printf "%.0f", s/n}')
      CPU_NORM=$(awk "BEGIN {printf \"%.2f\", $CPU_PCT/100}")
      sketchybar --push cpu "$CPU_NORM"
      sketchybar --set cpu label="''${CPU_PCT}%"
    '';
  };

  # === SketchyBar 本体設定 ===
  programs.sketchybar = {
    enable = true;
    configType = "bash";
    extraPackages = with pkgs; [ jq ];
    config = ''
      # === Gruvbox Dark カラー定義 ===
      TRANSPARENT=0x00000000
      BG=0xff3c3836
      TEXT=0xffebdbb2
      INACTIVE=0xff928374
      HIGHLIGHT=0xfffbf1c7

      # ウィジェットごとのテーマカラー (参考: SoichiroYamane/dotfiles の cmap)
      CLR_RED=0xffcc241d
      CLR_ORANGE=0xffd65d0e
      CLR_YELLOW=0xffd79921
      CLR_GREEN=0xff98971a
      CLR_AQUA=0xff689d6a
      CLR_BLUE=0xff458588
      CLR_PURPLE=0xffb16286
      CLR_BLUE_BR=0xff83a598
      CLR_PURPLE_BR=0xffd3869b

      # ワークスペースカラーマップ
      CMAP=($CLR_RED $CLR_ORANGE $CLR_YELLOW $CLR_GREEN $CLR_AQUA $CLR_BLUE $CLR_PURPLE $CLR_BLUE_BR $CLR_PURPLE_BR)

      # === バー全体 (完全透過 + ブラー) ===
      sketchybar --bar \
        height=32 \
        position=top \
        color=$TRANSPARENT \
        border_width=0 \
        padding_left=8 \
        padding_right=8 \
        margin=0 \
        y_offset=0 \
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
      for i in $(seq 1 9); do
        COLOR=''${CMAP[$((i-1))]}
        sketchybar --add item space.$i left \
                   --set space.$i \
                     icon="$i" \
                     icon.font="SauceCodePro Nerd Font Mono:Bold:14.0" \
                     icon.color=$COLOR \
                     icon.padding_left=8 \
                     icon.padding_right=4 \
                     label.font="SauceCodePro Nerd Font Mono:Medium:13.0" \
                     label.color=$COLOR \
                     label.drawing=off \
                     background.drawing=off \
                     update_freq=5 \
                     script="
                       # ワークスペースのフォーカス状態を更新
                       if [ \"\$AEROSPACE_FOCUSED_WORKSPACE\" = \"$i\" ]; then
                         sketchybar --set \$NAME background.drawing=on background.color=$COLOR background.corner_radius=6 background.height=26 icon.color=$HIGHLIGHT label.color=$HIGHLIGHT
                       else
                         sketchybar --set \$NAME background.drawing=off icon.color=$COLOR label.color=$COLOR
                       fi
                       # ワークスペース内アプリアイコンを更新
                       $HOME/.config/sketchybar/helpers/workspace_icons.sh $i
                     " \
                   --subscribe space.$i aerospace_workspace_change
      done

      # ワークスペース bracket
      sketchybar --add bracket bracket.spaces space.1 space.2 space.3 space.4 space.5 space.6 space.7 space.8 space.9 \
                 --set bracket.spaces \
                   background.color=$BG \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_YELLOW

      # ============================================================
      #  CENTER: フロントアプリ名 (アイコン付き)
      # ============================================================
      sketchybar --add item front_app center \
                 --set front_app \
                   icon.drawing=on \
                   icon.font="SauceCodePro Nerd Font Mono:Bold:16.0" \
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
                   update_freq=30 \
                   script='sketchybar --set $NAME label="$(date "+%H:%M")"'

      sketchybar --add item cal.date right \
                 --set cal.date \
                   icon.drawing=off \
                   label.color=$CLR_BLUE \
                   update_freq=60 \
                   script='sketchybar --set $NAME label="$(date "+%m/%d %a")"'

      sketchybar --add bracket bracket.cal cal.time cal.date \
                 --set bracket.cal \
                   background.color=$BG \
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
                   update_freq=120 \
                   script='
                     PERCENTAGE="$(pmset -g batt | grep -Eo "[0-9]+%" | head -1 | tr -d "%")"
                     CHARGING="$(pmset -g batt | grep -c "AC Power")"
                     if [ "$CHARGING" -gt 0 ]; then
                       ICON="󰂄"
                     elif [ "$PERCENTAGE" -le 10 ]; then
                       ICON="󰁺"
                     elif [ "$PERCENTAGE" -le 25 ]; then
                       ICON="󰁻"
                     elif [ "$PERCENTAGE" -le 50 ]; then
                       ICON="󰁾"
                     elif [ "$PERCENTAGE" -le 75 ]; then
                       ICON="󰂁"
                     else
                       ICON="󰁹"
                     fi
                     sketchybar --set $NAME icon="$ICON" label="''${PERCENTAGE}%"
                   '

      sketchybar --add bracket bracket.battery battery \
                 --set bracket.battery \
                   background.color=$BG \
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
                     VOLUME="$(osascript -e "output volume of (get volume settings)" 2>/dev/null || echo 0)"
                     MUTED="$(osascript -e "output muted of (get volume settings)" 2>/dev/null || echo false)"
                     if [ "$MUTED" = "true" ]; then
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
                   background.color=$BG \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_GREEN

      sketchybar --add item padding.volume right --set padding.volume width=6

      # --- ネットワーク (purple) ---
      sketchybar --add item network right \
                 --set network \
                   icon.color=$CLR_PURPLE \
                   label.color=$CLR_PURPLE \
                   update_freq=5 \
                   script='
                     SSID="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk "/ SSID/ {print \$2}")"
                     if [ -z "$SSID" ]; then
                       IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"
                       if [ -n "$IP" ]; then
                         sketchybar --set $NAME icon="󰈀" label="$IP"
                       else
                         sketchybar --set $NAME icon="󰖪" label="未接続"
                       fi
                     else
                       sketchybar --set $NAME icon="󰖩" label="$SSID"
                     fi
                   '

      sketchybar --add bracket bracket.network network \
                 --set bracket.network \
                   background.color=$BG \
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
                   update_freq=10 \
                   script='
                     MEM_TOTAL=$(sysctl -n hw.memsize)
                     PAGESIZE=$(pagesize)
                     ACTIVE=$(vm_stat | awk "/Pages active/ {print \$NF}" | tr -d ".")
                     WIRED=$(vm_stat | awk "/Pages wired/ {print \$NF}" | tr -d ".")
                     COMP=$(vm_stat | awk "/occupied by compressor/ {print \$NF}" | tr -d ".")
                     MEM_USED=$(( (ACTIVE + WIRED + COMP) * PAGESIZE ))
                     MEM_PCT=$(( MEM_USED * 100 / MEM_TOTAL ))
                     sketchybar --set $NAME label="''${MEM_PCT}%"
                   '

      sketchybar --add bracket bracket.mem mem \
                 --set bracket.mem \
                   background.color=$BG \
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
                   graph.fill_color=$CLR_AQUA \
                   update_freq=2 \
                   script='$HOME/.config/sketchybar/helpers/cpu_update.sh'

      sketchybar --add bracket bracket.cpu cpu \
                 --set bracket.cpu \
                   background.color=$BG \
                   background.corner_radius=8 \
                   background.height=26 \
                   background.border_width=2 \
                   background.border_color=$CLR_AQUA

      # === 初期化完了 ===
      sketchybar --update
    '';
  };
}
