{ pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    configType = "bash";
    extraPackages = with pkgs; [ jq ];
    config = ''
      # === バー全体の設定 ===
      sketchybar --bar \
        height=32 \
        position=top \
        color=0xff282828 \
        border_color=0xff3c3836 \
        border_width=1 \
        padding_left=10 \
        padding_right=10 \
        margin=0 \
        y_offset=0 \
        corner_radius=0 \
        blur_radius=20 \
        sticky=on \
        topmost=off

      # === デフォルトアイテム設定 ===
      sketchybar --default \
        icon.font="Hack Nerd Font:Bold:14.0" \
        icon.color=0xffebdbb2 \
        label.font="Hack Nerd Font:Bold:13.0" \
        label.color=0xffebdbb2 \
        background.color=0xff3c3836 \
        background.corner_radius=5 \
        background.height=24 \
        background.padding_left=5 \
        background.padding_right=5 \
        padding_left=2 \
        padding_right=2

      # === ワークスペース表示 (AeroSpace連携) ===
      for i in $(seq 1 9); do
        sketchybar --add item space.$i left \
                   --set space.$i \
                     icon="$i" \
                     icon.padding_left=8 \
                     icon.padding_right=8 \
                     background.drawing=off \
                     script="
                       if [ \"\$AEROSPACE_FOCUSED_WORKSPACE\" = \"$i\" ]; then
                         sketchybar --set \$NAME background.drawing=on icon.color=0xfffbf1c7
                       else
                         sketchybar --set \$NAME background.drawing=off icon.color=0xff928374
                       fi
                     " \
                   --subscribe space.$i aerospace_workspace_change
      done

      # === フロントアプリ名 ===
      sketchybar --add item front_app center \
                 --set front_app \
                   icon.drawing=off \
                   label.font="Hack Nerd Font:Bold:13.0" \
                   script='sketchybar --set $NAME label="$INFO"' \
                 --subscribe front_app front_app_switched

      # === 時計 ===
      sketchybar --add item clock right \
                 --set clock \
                   icon="" \
                   icon.padding_left=8 \
                   label.padding_right=8 \
                   update_freq=30 \
                   script='sketchybar --set $NAME label="$(date "+%m/%d %H:%M")"'

      # === バッテリー ===
      sketchybar --add item battery right \
                 --set battery \
                   icon.padding_left=8 \
                   label.padding_right=8 \
                   update_freq=120 \
                   script='
                     PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | head -1)"
                     CHARGING="$(pmset -g batt | grep -c "AC Power")"
                     if [ "$CHARGING" -gt 0 ]; then
                       ICON=""
                     else
                       ICON=""
                     fi
                     sketchybar --set $NAME icon="$ICON" label="$PERCENTAGE"
                   '

      # === 初期化完了 ===
      sketchybar --update
    '';
  };
}
