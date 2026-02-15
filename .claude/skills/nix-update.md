# Nix Update

Nixチャンネルを最新に更新し、Home Managerの設定を適用します。パッケージの更新やセキュリティパッチの適用に使用します。

## 機能

- Nixチャンネルの更新
- Home-Managerチャンネルの更新
- 更新後にHome Manager設定を自動適用

## 引数

- `--skip-switch` (オプション): チャンネル更新のみでHome Manager適用をスキップ

## 実行コマンド

```bash
#!/bin/bash
set -e

SKIP_SWITCH=false

# 引数の解析
for arg in "$@"; do
  case $arg in
    --skip-switch)
      SKIP_SWITCH=true
      shift
      ;;
  esac
done

echo "🔄 Nixチャンネルを更新中..."

# 現在のチャンネルを表示
echo "📡 現在のチャンネル:"
nix-channel --list

# チャンネルを更新
echo ""
echo "⬇️  更新をダウンロード中..."
nix-channel --update

echo ""
echo "✅ Nixチャンネルの更新が完了しました"

# Home Managerを適用
if [ "$SKIP_SWITCH" = false ]; then
  echo ""
  echo "🏠 Home Managerの設定を適用中..."
  home-manager switch

  if [ $? -eq 0 ]; then
    echo "✅ 環境の更新が完了しました"
  else
    echo "❌ Home Managerの適用に失敗しました"
    echo "手動で実行してください: home-manager switch --show-trace"
    exit 1
  fi
else
  echo ""
  echo "⏭️  Home Manager適用をスキップしました"
  echo "適用するには: home-manager switch"
fi

# 更新されたチャンネルを表示
echo ""
echo "📡 更新後のチャンネル:"
nix-channel --list
```

## 使用例

```bash
# チャンネル更新とHome Manager適用
/nix-update

# チャンネル更新のみ
/nix-update --skip-switch
```

## 注意事項

- 更新には時間がかかる場合があります（数分～数十分）
- インターネット接続が必要です
- 更新後に問題が発生した場合は、`home-manager switch --rollback`でロールバックできます

## 関連コマンド

- `/home-manager-switch` - Home Manager設定のみを適用
- `/dotfiles-apply` - 手動管理のdotfilesを適用
