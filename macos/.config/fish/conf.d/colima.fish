# Colima自動起動チェック（軽量版）
# colima status (~800ms) の代わりにソケットファイルの存在で判定 (~0ms)
# Non-interactive shells (fish -c, scripts, Home Manager activation) must stay quiet.
if status is-interactive
    if command -v colima >/dev/null
        if not test -S "$HOME/.colima/default/docker.sock"
            echo "🐳 Colimaを起動中..."
            colima start >/dev/null 2>&1 &
        end
    end
end
