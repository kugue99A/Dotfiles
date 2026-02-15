# Setup Environment

macOS開発環境を完全にセットアップします。このskillは、Nix設定とdotfiles設定の両方を適用し、完全な開発環境を構築します。

## 機能

1. Nixチャンネルの更新
2. Home Manager設定の適用（パッケージ、シェル、Git等）
3. Dotfiles設定の適用（Neovim、Zellij、WezTerm等）
4. Fish shellプラグインのインストール
5. Neovimプラグインのインストール

## 引数

- `--skip-nix-update` (オプション): Nixチャンネルの更新をスキップ
- `--nix-only` (オプション): Nix設定のみ適用
- `--dotfiles-only` (オプション): Dotfiles設定のみ適用

## 事前準備

このskillを実行する前に、以下を確認してください:

1. Nixがインストールされている
2. Home Managerがインストールされている
3. `~/.config/home-manager/home.nix`のユーザー情報が正しい
4. `~/.config/home-manager/git.nix`のGitユーザー情報が設定されている

## 実行コマンド

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR/../.."

SKIP_NIX_UPDATE=false
NIX_ONLY=false
DOTFILES_ONLY=false

# 引数の解析
for arg in "$@"; do
  case $arg in
    --skip-nix-update)
      SKIP_NIX_UPDATE=true
      shift
      ;;
    --nix-only)
      NIX_ONLY=true
      shift
      ;;
    --dotfiles-only)
      DOTFILES_ONLY=true
      shift
      ;;
  esac
done

echo "🚀 macOS開発環境のセットアップを開始します"
echo ""

# Step 1: Nix設定の適用
if [ "$DOTFILES_ONLY" = false ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 Step 1/4: Nix環境の設定"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [ "$SKIP_NIX_UPDATE" = false ]; then
    echo "🔄 Nixチャンネルを更新中..."
    nix-channel --update
  else
    echo "⏭️  Nixチャンネルの更新をスキップ"
  fi

  echo ""
  echo "🏠 Home Manager設定を適用中..."
  home-manager switch

  if [ $? -eq 0 ]; then
    echo "✅ Nix環境の設定が完了しました"
  else
    echo "❌ Home Managerの適用に失敗しました"
    exit 1
  fi
fi

# Step 2: Dotfiles設定の適用
if [ "$NIX_ONLY" = false ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 Step 2/4: Dotfiles設定の適用"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$DOTFILES_ROOT"

  echo "📋 適用内容:"
  ./dotfiles plan

  echo ""
  echo "⚙️  適用中..."
  ./dotfiles apply

  if [ $? -eq 0 ]; then
    echo "✅ Dotfiles設定が完了しました"
  else
    echo "❌ Dotfiles設定に失敗しました"
    exit 1
  fi
fi

# Step 3: Fish shellプラグインのインストール
if [ "$NIX_ONLY" = false ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🐚 Step 3/4: Fish shellプラグインのインストール"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if command -v fish >/dev/null 2>&1; then
    echo "Fisher プラグインマネージャーをインストール中..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"
    echo "✅ Fish shellプラグインのインストールが完了しました"
  else
    echo "⚠️  Fish shellが見つかりません。スキップします。"
  fi
fi

# Step 4: Neovimプラグインのインストール
if [ "$NIX_ONLY" = false ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📝 Step 4/4: Neovimプラグインのインストール"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if command -v nvim >/dev/null 2>&1; then
    echo "Lazy.nvimでプラグインを同期中..."
    nvim --headless "+Lazy! sync" +qa
    echo "✅ Neovimプラグインのインストールが完了しました"
  else
    echo "⚠️  Neovimが見つかりません。スキップします。"
  fi
fi

# 完了メッセージ
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 環境セットアップが完了しました！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 適用された設定:"
echo "  • パッケージ: $(home-manager packages | wc -l) 個"
echo "  • Dotfiles: $(ls -1 ~/.config | wc -l) 項目"
echo ""
echo "💡 次のステップ:"
echo "  1. ターミナルを再起動してください"
echo "  2. Neovimを起動して :checkhealth を実行"
echo "  3. Fish shellで fisher list を実行してプラグインを確認"
echo ""
echo "🔧 設定の確認:"
echo "  /dotfiles-status     - Dotfiles状態を確認"
echo "  home-manager generations - Nix世代を確認"
```

## 使用例

```bash
# 完全セットアップ
/setup-environment

# Nixチャンネル更新をスキップ
/setup-environment --skip-nix-update

# Nix設定のみ適用
/setup-environment --nix-only

# Dotfiles設定のみ適用
/setup-environment --dotfiles-only
```

## トラブルシューティング

### Home Managerエラーが発生した場合

```bash
# 詳細なエラーログを表示
home-manager switch --show-trace

# 前の世代にロールバック
home-manager switch --rollback
```

### Dotfilesエラーが発生した場合

```bash
# バックアップから復元
cat .dotfiles_state  # バックアップ場所を確認
cp -r ~/.config.backup/YYYYMMDD_HHMMSS/* ~/.config/
```

## 関連コマンド

- `/home-manager-switch` - Home Manager設定を再適用
- `/nix-update` - Nixチャンネルを更新
- `/dotfiles-apply` - Dotfiles設定を再適用
- `/dotfiles-status` - 現在の設定状態を確認
