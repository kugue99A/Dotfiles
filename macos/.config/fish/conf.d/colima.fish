# Colima自動起動チェック
if command -v colima >/dev/null
    # Colimaが停止していたら自動起動
    if not colima status >/dev/null 2>&1
        echo "🐳 Colimaを起動中..."
        colima start >/dev/null 2>&1 &
    end
end
