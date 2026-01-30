{ pkgs, ... }:

{
  programs.aerospace = {
    enable = true;
    settings = {
      # i3ライクなタイリング設定
      after-login-command = [];
      after-startup-command = [];

      # ウィンドウ間のギャップ
      gaps = {
        inner.horizontal = 10;
        inner.vertical = 10;
        outer.left = 10;
        outer.bottom = 10;
        outer.top = 10;
        outer.right = 10;
      };

      mode.main.binding = {
        # ウィンドウフォーカス移動 (cmd-alt-hjkl)
        "cmd-alt-h" = "focus left";
        "cmd-alt-j" = "focus down";
        "cmd-alt-k" = "focus up";
        "cmd-alt-l" = "focus right";

        # ウィンドウ移動 (cmd-alt-shift-hjkl)
        "cmd-alt-shift-h" = "move left";
        "cmd-alt-shift-j" = "move down";
        "cmd-alt-shift-k" = "move up";
        "cmd-alt-shift-l" = "move right";

        # ワークスペース切替 (alt-数字)
        "alt-1" = "workspace 1";
        "alt-2" = "workspace 2";
        "alt-3" = "workspace 3";
        "alt-4" = "workspace 4";
        "alt-5" = "workspace 5";
        "alt-6" = "workspace 6";
        "alt-7" = "workspace 7";
        "alt-8" = "workspace 8";
        "alt-9" = "workspace 9";

        # ウィンドウをワークスペースに移動 (alt-shift-数字)
        "alt-shift-1" = "move-node-to-workspace 1";
        "alt-shift-2" = "move-node-to-workspace 2";
        "alt-shift-3" = "move-node-to-workspace 3";
        "alt-shift-4" = "move-node-to-workspace 4";
        "alt-shift-5" = "move-node-to-workspace 5";
        "alt-shift-6" = "move-node-to-workspace 6";
        "alt-shift-7" = "move-node-to-workspace 7";
        "alt-shift-8" = "move-node-to-workspace 8";
        "alt-shift-9" = "move-node-to-workspace 9";

        # レイアウト
        "alt-slash" = "layout tiles horizontal vertical"; # 水平/垂直トグル
        "alt-comma" = "layout accordion horizontal vertical"; # アコーディオントグル
        "alt-f" = "fullscreen"; # フルスクリーントグル

        # ウィンドウリサイズモードに入る
        "alt-r" = "mode resize";
      };

      # リサイズモード
      mode.resize.binding = {
        "h" = "resize width -50";
        "j" = "resize height +50";
        "k" = "resize height -50";
        "l" = "resize width +50";
        "enter" = "mode main";
        "esc" = "mode main";
      };
    };
  };
}
