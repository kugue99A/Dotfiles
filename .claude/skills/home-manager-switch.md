# Home Manager Switch

Home Managerの設定を適用します。このskillは、~/.config/home-manager/配下のNix設定ファイルを読み込み、パッケージやシェル設定を宣言的に適用します。

## 機能

- パッケージのインストール/更新
- Fish shell、Git、Lazygit、ターミナルツールの設定適用
- 環境変数の設定
- 世代管理（ロールバック可能）

## 引数

なし

## 事前確認

このskillを実行する前に、以下を確認してください:

1. `~/.config/home-manager/home.nix`のユーザー情報が正しい
2. `~/.config/home-manager/git.nix`のメールアドレスが設定されている

## 実行コマンド

```bash
#!/bin/bash
set -e

echo "🏠 Home Managerの設定を適用中..."

# Home Manager設定ディレクトリの確認
if [ ! -d "$HOME/.config/home-manager" ]; then
  echo "❌ エラー: ~/.config/home-manager が見つかりません"
  exit 1
fi

# 設定ファイルの構文チェック（オプション）
echo "📝 設定ファイルの構文チェック中..."
nix-instantiate --parse ~/.config/home-manager/home.nix > /dev/null 2>&1 || {
  echo "⚠️  構文エラーがある可能性があります"
}

# Home Managerを適用
echo "⚙️  適用中..."
home-manager switch

# 結果の確認
if [ $? -eq 0 ]; then
  echo "✅ Home Managerの適用が完了しました"
  echo ""
  echo "📦 適用されたパッケージ:"
  home-manager packages | head -20
  echo ""
  echo "🔄 世代を確認するには: home-manager generations"
  echo "↩️  ロールバックするには: home-manager switch --rollback"
else
  echo "❌ Home Managerの適用に失敗しました"
  exit 1
fi
```

## トラブルシューティング

### エラーが発生した場合

```bash
# 詳細なエラーログを表示
home-manager switch --show-trace

# チャンネルを更新してから再試行
nix-channel --update && home-manager switch

# 前の世代にロールバック
home-manager switch --rollback
```

### 世代管理

```bash
# 世代一覧を表示
home-manager generations

# 特定の世代をアクティブ化
/nix/store/[generation-path]/activate
```

## 関連コマンド

- `/nix-update` - Nixチャンネルを更新
- `/dotfiles-apply` - 手動管理のdotfilesを適用
