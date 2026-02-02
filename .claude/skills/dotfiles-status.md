# Dotfiles Status

現在のdotfiles設定状態を確認します。すべての設定ファイルの管理状態とシンボリックリンクの整合性を表示します。

## 機能

- 全設定ファイルの管理状態を表示
- シンボリックリンクの整合性を確認
- Nix管理/手動管理を区別
- 最終適用日時とバックアップ場所を表示

## 引数

なし

## 実行コマンド

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR/../.."

echo "📊 Dotfiles設定状態"
echo ""

cd "$DOTFILES_ROOT"
./dotfiles status

echo ""
echo "💡 利用可能なコマンド:"
echo "  /dotfiles-plan   - 変更内容を確認"
echo "  /dotfiles-apply  - 設定を適用"
echo "  /home-manager-switch - Nix管理の設定を適用"
```

## 出力例

```
State file: /Users/username/Workspace/Dotfiles/.dotfiles_state
applied_at=2025-08-09T02:09:46Z
backup_dir=/Users/username/.config.backup/20250809_110946

  nvim: ✓ symlinked
  zellij: ✓ symlinked
  fish: ✓ symlinked
  starship.toml: managed by nix
  wezterm: ✓ symlinked
```

## 状態の意味

- `✓ symlinked` 正しくシンボリックリンクされている
- `managed by nix` Nix/Home Managerで管理されている
- `missing` リンクが存在しない
- `broken` リンク先が見つからない

## 関連コマンド

- `/dotfiles-plan` - 変更内容を確認
- `/dotfiles-apply` - 設定を適用
