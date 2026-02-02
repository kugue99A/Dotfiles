# Dotfiles Plan

Dotfiles設定の変更内容を事前に確認します（dry-run）。実際のファイルは変更せず、どのような操作が行われるかをプレビューします。

## 機能

- シンボリックリンクの作成/更新予定を表示
- Nix管理ファイルを自動検出して除外
- 現在の設定状態との差分を確認

## 引数

なし

## 実行コマンド

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR/../.."

echo "📋 Dotfiles変更内容の確認中..."
echo ""

cd "$DOTFILES_ROOT"
./dotfiles plan

echo ""
echo "💡 変更を適用するには: /dotfiles-apply を実行してください"
```

## 出力例

```
+ nvim: will be symlinked
+ zellij: will be symlinked
~ fish: symlink will be updated
  starship.toml: managed by nix (skipped)
```

## 記号の意味

- `+` 新規作成されるシンボリックリンク
- `~` 更新されるシンボリックリンク
- `✓` すでに正しくリンクされている
- `managed by nix` Nix/Home Managerで管理されているため除外

## 関連コマンド

- `/dotfiles-apply` - 変更を実際に適用
- `/dotfiles-status` - 現在の設定状態を確認
