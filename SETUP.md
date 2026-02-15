# macOS開発環境セットアップガイド

このリポジトリは、macOS開発環境を自動でセットアップするためのDotfilesリポジトリです。

## 概要

このリポジトリは以下の2つの管理システムを統合しています：

1. **Nix / Home Manager** - パッケージと基本設定の宣言的管理
2. **Dotfiles Script** - Neovim、Zellij等の詳細設定の管理

## 事前準備

### 1. Nixのインストール

```bash
# マルチユーザーインストール（推奨）
sh <(curl -L https://nixos.org/nix/install)

# Nix flakesを有効化
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 2. Home Managerのインストール

```bash
# Home Managerチャンネルを追加
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# Home Managerをインストール
nix-shell '<home-manager>' -A install
```

## パーソナライズ設定

環境を適用する前に、以下のファイルを**必ず**編集してください：

### 1. Home Manager設定 - ユーザー情報

**ファイル**: `macos/.config/home-manager/home.nix`

```nix
{
  # 現在のユーザー名に変更
  home.username = "yoheikugue";  # ← 変更必要

  # 現在のホームディレクトリに変更
  home.homeDirectory = "/Users/yoheikugue";  # ← 変更必要

  home.stateVersion = "25.05";  # 変更不要
}
```

**確認方法**:
```bash
# ユーザー名を確認
whoami

# ホームディレクトリを確認
echo $HOME
```

### 2. Git設定 - ユーザー情報

**ファイル**: `macos/.config/home-manager/git.nix`

```nix
{
  programs.git = {
    enable = true;

    # あなたのGitユーザー名に変更
    userName = "yoheikugue";  # ← 変更必要

    # あなたのメールアドレスに変更
    userEmail = "your-email@example.com";  # ← 変更必須

    # ...その他の設定
  };
}
```

**現在のGit設定を確認**:
```bash
git config --global user.name
git config --global user.email
```

## クイックスタート

### 方法1: Claude Code Skillsを使う（推奨）

このリポジトリには、環境セットアップを自動化するClaude Code Skillsが含まれています。

```bash
# リポジトリをクローン
git clone <repository-url> ~/Workspace/Dotfiles
cd ~/Workspace/Dotfiles

# Claude Codeで以下のスキルを実行
/setup-environment
```

このコマンドは以下を自動実行します：
1. Nixチャンネルの更新
2. Home Manager設定の適用（パッケージインストール）
3. Dotfiles設定の適用（シンボリックリンク作成）
4. Fish shellプラグインのインストール
5. Neovimプラグインのインストール

### 方法2: 手動セットアップ

#### Step 1: Nix設定の適用

```bash
# Nixチャンネルを更新
nix-channel --update

# Home Manager設定を適用
cd ~/Workspace/Dotfiles
home-manager switch --flake macos/.config/home-manager
```

これにより以下がインストール・設定されます：
- 開発ツール（git, gh, neovim, zellij, starship等）
- LSPサーバー（lua, typescript, go, rust, python等）
- CLIツール（ripgrep, fd, bat, fzf, lsd等）
- Shell設定（Fish shell設定とエイリアス）

#### Step 2: Dotfiles設定の適用

```bash
cd ~/Workspace/Dotfiles

# 変更内容を確認（dry-run）
./dotfiles plan

# 設定を適用
./dotfiles apply
```

これにより以下がシンボリックリンクされます：
- Neovim設定（~/.config/nvim）
- Zellij設定（~/.config/zellij）
- WezTerm設定（~/.config/wezterm）
- その他各種ツール設定

#### Step 3: プラグインのインストール

```bash
# Fish shellプラグインをインストール
fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher update
exit

# Neovimプラグインをインストール
nvim --headless "+Lazy! sync" +qa
```

## Claude Code Skills

このリポジトリには以下のSkillsが用意されています：

### 環境管理

- `/setup-environment` - 完全な環境セットアップ
  - `--skip-nix-update` - Nix更新をスキップ
  - `--nix-only` - Nix設定のみ
  - `--dotfiles-only` - Dotfiles設定のみ

### Nix / Home Manager

- `/home-manager-switch` - Home Manager設定を適用
- `/nix-update` - Nixチャンネルを更新＆適用
  - `--skip-switch` - 更新のみで適用はスキップ

### Dotfiles管理

- `/dotfiles-plan` - 変更内容を確認（dry-run）
- `/dotfiles-apply` - Dotfiles設定を適用
- `/dotfiles-status` - 現在の設定状態を確認

## 主要コマンド

### Dotfiles管理（Terraform風）

```bash
# 現在の状態を確認
./dotfiles status

# 変更内容を確認（dry-run）
./dotfiles plan

# 設定を適用
./dotfiles apply

# 設定を削除（シンボリックリンクを削除）
./dotfiles destroy
```

### Home Manager管理

```bash
# 設定を適用
home-manager switch

# 世代を確認（ロールバック用）
home-manager generations

# 前の世代にロールバック
home-manager switch --rollback

# エラー詳細を表示
home-manager switch --show-trace
```

### プラグイン管理

```bash
# Neovimプラグイン
nvim +:Lazy sync     # 同期
nvim +:Lazy update   # 更新

# Fish shellプラグイン
fisher update        # 更新
fisher list          # 一覧表示
```

## トラブルシューティング

### Home Managerエラー

```bash
# 詳細なエラーログを表示
home-manager switch --show-trace

# チャンネルを更新して再試行
nix-channel --update
home-manager switch

# 前の世代にロールバック
home-manager switch --rollback
```

### Dotfilesエラー

```bash
# バックアップ場所を確認
cat .dotfiles_state

# バックアップから復元
cp -r ~/.config.backup/YYYYMMDD_HHMMSS/* ~/.config/

# 状態ファイルをリセット
rm .dotfiles_state
./dotfiles apply
```

### Neovim LSPエラー

```bash
# LSPステータスを確認
nvim
:LspInfo

# Mason経由でLSPを再インストール（必要に応じて）
:Mason

# ヘルスチェック
:checkhealth
```

## 設定の詳細

### インストールされるパッケージ

**開発ツール**:
- Neovim（モダンなVimエディタ）
- Git, GitHub CLI (gh)
- Starship（モダンなシェルプロンプト）

**CLIツール**:
- ripgrep (rg) - 高速grep
- fd - 高速find
- bat - catの代替（シンタックスハイライト）
- fzf - ファジーファインダー
- lsd - lsの代替（アイコン表示）
- lazygit - Git TUI
- delta - Git差分表示
- ghq - リポジトリ管理
- zellij - ターミナルマルチプレクサ
- zoxide - スマートcd

**LSPサーバー**（9種類）:
- lua-language-server（Lua）
- nil（Nix）
- typescript-language-server（TypeScript/JavaScript）
- vscode-langservers-extracted（HTML/CSS/JSON）
- gopls（Go）
- rust-analyzer（Rust）
- markdown-oxide（Markdown）
- deno（Deno）
- pyright（Python）

**言語実行環境**:
- Go, Rust, Python, Lua

### 設定されるエイリアス（Fish shell）

```fish
vim → nvim
vi → nvim
ls → lsd
ll → lsd -l
la → lsd -la
cat → bat
grep → rg
find → fd

# Git shortcuts
gs → git status
ga → git add
gc → git commit
gp → git push
gl → git pull
gd → git diff

# ディレクトリ移動
.. → cd ..
... → cd ../..
.... → cd ../../..
```

### Neovim設定

- **Leader key**: Space
- **Local leader**: Backslash
- **プラグインマネージャー**: lazy.nvim
- **LSP管理**: vim.lsp.config（Masonは不使用）
- **テーマ**: Tokyo Night / Gruvbox Dark
- **主要プラグイン**:
  - telescope（ファジーファインダー）
  - neo-tree（ファイルエクスプローラー）
  - lspsaga（LSP UI拡張）
  - nvim-cmp（補完）
  - treesitter（構文解析）
  - bufferline（バッファ表示）
  - which-key（キーマップヘルプ）

### Zellij設定

- **Prefix key**: Ctrl+q（tmux互換）
- **ペーン移動**: hjkl（Vim風）
- **ペーン分割**: s（水平）、v（垂直）
- **テーマ**: Gruvbox Dark

## ファイル構造

```
Dotfiles/
├── dotfiles                    # Terraform風管理スクリプト
├── .dotfiles_state             # 状態管理ファイル
├── .claude/
│   └── skills/                 # Claude Code Skills
│       ├── setup-environment.md
│       ├── home-manager-switch.md
│       ├── nix-update.md
│       ├── dotfiles-apply.md
│       ├── dotfiles-plan.md
│       └── dotfiles-status.md
├── macos/
│   └── .config/
│       ├── home-manager/       # Nix設定
│       │   ├── home.nix       # メイン設定（要パーソナライズ）
│       │   ├── packages.nix   # パッケージ定義
│       │   ├── shell.nix      # Fish shell設定
│       │   ├── git.nix        # Git設定（要パーソナライズ）
│       │   └── terminal.nix   # ターミナルツール設定
│       ├── nvim/              # Neovim設定
│       ├── zellij/            # Zellij設定
│       ├── fish/              # Fish shell設定
│       ├── wezterm/           # WezTerm設定
│       ├── lazygit/           # Lazygit設定
│       ├── mise/              # Mise設定
│       └── ...
├── CLAUDE.md                   # リポジトリ説明（プロジェクト用）
└── SETUP.md                    # このファイル
```

## アンインストール

### Dotfilesのみ削除

```bash
cd ~/Workspace/Dotfiles
./dotfiles destroy
```

### Home Manager削除

```bash
# Home Managerをアンインストール
home-manager uninstall

# Nixチャンネルを削除
nix-channel --remove home-manager
```

### Nixの完全削除

```bash
# Nixをアンインストール
/nix/nix-installer uninstall

# または手動削除
sudo rm -rf /nix
```

## 参考リンク

- [Nix Package Manager](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Neovim](https://neovim.io/)
- [Fish Shell](https://fishshell.com/)
- [Zellij](https://zellij.dev/)
- [Claude Code](https://claude.ai/code)

## サポート

問題が発生した場合：

1. `/dotfiles-status`で現在の状態を確認
2. `home-manager switch --show-trace`で詳細エラーを確認
3. バックアップから復元: `cp -r ~/.config.backup/YYYYMMDD_HHMMSS/* ~/.config/`
4. Issueを作成してください
