# Dotfiles Apply

手動管理のdotfiles設定を適用します。macos/.config/配下の設定ファイルを~/.config/にシンボリックリンクとして配置します。

## 機能

- シンボリックリンクの作成/更新
- 既存ファイルの自動バックアップ
- Nix管理ファイルの自動スキップ
- 状態管理（.dotfiles_state）

## 対象ファイル

- Neovim設定（nvim/）
- Zellij設定（zellij/）
- WezTerm設定（wezterm/）
- Fish shell設定（fish/）
- Lazygit設定（lazygit/）
- その他開発ツール設定

## 引数

なし

## 実行コマンド

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR/../.."

echo "🔧 Dotfiles設定を適用中..."
echo ""

# 変更内容を確認
echo "📋 適用内容:"
cd "$DOTFILES_ROOT"
./dotfiles plan

echo ""
read -p "この内容で適用しますか？ (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "⚙️  適用中..."
  ./dotfiles apply

  if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Dotfilesの適用が完了しました"
    echo ""
    echo "📁 バックアップ場所:"
    cat .dotfiles_state | grep backup_dir
    echo ""
    echo "💡 設定を有効にするには:"
    echo "  - Neovim: 再起動してください"
    echo "  - Fish: source ~/.config/fish/config.fish"
    echo "  - Zellij: 新しいセッションを開始してください"
  else
    echo "❌ Dotfilesの適用に失敗しました"
    exit 1
  fi
else
  echo "❌ 適用をキャンセルしました"
  exit 0
fi
```

## 安全性

- 既存ファイルは自動的にバックアップされます（~/.config.backup/YYYYMMDD_HHMMSS/）
- Nix管理のファイルは自動的にスキップされます
- 状態は.dotfiles_stateファイルで追跡されます

## バックアップからの復元

```bash
# バックアップディレクトリを確認
cat .dotfiles_state

# 手動で復元
cp -r ~/.config.backup/YYYYMMDD_HHMMSS/* ~/.config/
```

## 関連コマンド

- `/dotfiles-plan` - 適用前に変更内容を確認
- `/dotfiles-status` - 現在の設定状態を確認
- `/home-manager-switch` - Nix管理の設定を適用
