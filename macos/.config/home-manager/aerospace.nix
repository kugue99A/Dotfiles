{ pkgs, ... }:

{
  # Raw TOML で直接記述 (Nix TOML ジェネレータはドットキー形式を出力できないため)
  # パッケージは packages.nix でインストール済み
  home.file.".config/aerospace/aerospace.toml".text = ''
    start-at-login = true

    # ウィンドウ正規化
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # 起動後にSketchyBarを起動
    after-login-command = []
    after-startup-command = ['exec-and-forget ${pkgs.sketchybar}/bin/sketchybar']

    # ワークスペース変更時にSketchyBarへ通知
    exec-on-workspace-change = [
        '/bin/bash', '-c',
        '${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change AEROSPACE_FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE AEROSPACE_PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE',
    ]

    # ウィンドウ間のギャップ
    # Studio Display: SketchyBar(32) + gap(4) = 36 (SketchyBarはメインディスプレイのみ表示)
    # デフォルト (内蔵等): 10 (通常のギャップのみ)
    [gaps]
    inner.horizontal = 10
    inner.vertical = 10
    outer.left = 10
    outer.bottom = 10
    outer.right = 10
    outer.top = [{monitor."Studio Display" = 36}, 10]

    # ウィンドウ検出時にSketchyBarのワークスペースアイコンを更新
    [[on-window-detected]]
    check-further-callbacks = true
    run = ['exec-and-forget /bin/bash -c "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change AEROSPACE_FOCUSED_WORKSPACE=$(${pkgs.aerospace}/bin/aerospace list-workspaces --focused)"']

    # 特定アプリをフローティングで開く
    [[on-window-detected]]
    if.app-id = 'com.apple.systempreferences'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.calculator'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.ActivityMonitor'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.AppStore'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.Passwords'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.keychainaccess'
    run = 'layout floating'

    # メインモード キーバインド
    [mode.main.binding]
    # ウィンドウフォーカス移動: alt-shift-hjkl
    alt-shift-h = 'focus left'
    alt-shift-j = 'focus down'
    alt-shift-k = 'focus up'
    alt-shift-l = 'focus right'

    # ウィンドウ移動: ctrl-alt-shift-hjkl
    ctrl-alt-shift-h = 'move left'
    ctrl-alt-shift-j = 'move down'
    ctrl-alt-shift-k = 'move up'
    ctrl-alt-shift-l = 'move right'

    # ウィンドウリサイズ: alt-shift-minus/equal
    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'

    # ワークスペース前後移動: alt-shift-n/p
    alt-shift-n = 'workspace next'
    alt-shift-p = 'workspace prev'

    # ワークスペース切替とフォーカス戻り: alt-shift-tab
    alt-shift-tab = 'workspace-back-and-forth'

    # ワークスペースをモニタ間で移動: ctrl-alt-shift-tab
    ctrl-alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    # ウィンドウを閉じる: alt-shift-x
    alt-shift-x = 'close'

    # レイアウト切替
    alt-shift-slash = 'layout tiles horizontal vertical'
    alt-shift-comma = 'layout accordion horizontal vertical'
    alt-shift-f = 'fullscreen'

    # フロート切替
    ctrl-alt-shift-f = 'layout floating tiling'

    # ワークスペース直接切替: alt-shift-数字
    alt-shift-1 = 'workspace 1'
    alt-shift-2 = 'workspace 2'
    alt-shift-3 = 'workspace 3'
    alt-shift-4 = 'workspace 4'
    alt-shift-5 = 'workspace 5'
    alt-shift-6 = 'workspace 6'
    alt-shift-7 = 'workspace 7'
    alt-shift-8 = 'workspace 8'
    alt-shift-9 = 'workspace 9'

    # ウィンドウをワークスペースに移動: ctrl-alt-shift-数字
    ctrl-alt-shift-1 = 'move-node-to-workspace 1'
    ctrl-alt-shift-2 = 'move-node-to-workspace 2'
    ctrl-alt-shift-3 = 'move-node-to-workspace 3'
    ctrl-alt-shift-4 = 'move-node-to-workspace 4'
    ctrl-alt-shift-5 = 'move-node-to-workspace 5'
    ctrl-alt-shift-6 = 'move-node-to-workspace 6'
    ctrl-alt-shift-7 = 'move-node-to-workspace 7'
    ctrl-alt-shift-8 = 'move-node-to-workspace 8'
    ctrl-alt-shift-9 = 'move-node-to-workspace 9'

    # サービスモードに入る: ctrl-alt-shift-semicolon
    ctrl-alt-shift-semicolon = 'mode service'

    # サービスモード (設定リロード・レイアウト管理)
    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    f = ['layout floating tiling', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']
  '';
}
