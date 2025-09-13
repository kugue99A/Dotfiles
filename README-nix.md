# Nix Home Manager Setup

このREADMEでは、Nix Home Managerを使用してDotfilesの設定を再現する手順を説明します。

## 前提条件

### 1. Nixのインストール

macOSの場合：
```bash
# Determinate Nixインストーラー（推奨）
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# または公式インストーラー
sh <(curl -L https://nixos.org/nix/install)
```

### 2. Home Managerのインストール

```bash
# Home Managerのチャンネルを追加
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# Home Managerをインストール
nix-shell '<home-manager>' -A install
```

## セットアップ手順

### 1. 設定ファイルの配置

```bash
# このリポジトリをクローン
git clone <your-repo-url> ~/Workspace/Dotfiles

# Home Manager設定ディレクトリを作成
mkdir -p ~/.config/home-manager

# 設定ファイルをコピーまたはシンボリックリンク
cp -r ~/Workspace/Dotfiles/macos/.config/home-manager/* ~/.config/home-manager/

# または、シンボリックリンクを作成（推奨）
ln -sf ~/Workspace/Dotfiles/macos/.config/home-manager/* ~/.config/home-manager/
```

### 2. メールアドレスの設定

`git.nix`ファイル内のメールアドレスを更新：

```bash
# git.nixを編集
vim ~/.config/home-manager/git.nix

# userEmailの行を自分のメールアドレスに変更
userEmail = "your-actual-email@example.com";
```

### 3. Home Managerの適用

```bash
# 設定を適用
home-manager switch

# エラーが発生した場合は、より詳細な出力で確認
home-manager switch --show-trace
```

### 4. シェルの設定

```bash
# Fish shellをデフォルトシェルに設定（オプション）
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)

# 新しいターミナルセッションを開始してFishシェルを使用
fish
```

## 設定ファイルの構成

設定は機能別に分割されています：

### `home.nix`
- メイン設定ファイル
- 他の設定ファイルをインポート
- ユーザー情報とHome Managerの基本設定

### `packages.nix`
- インストールするパッケージの一覧
- 開発ツール、CLI ツール、言語サーバーなど

### `shell.nix`
- Fish shellの設定
- エイリアス、関数、環境変数
- セッション変数

### `git.nix`
- Git設定
- Lazygit設定
- テーマとカラースキーム

### `terminal.nix`
- ターミナル関連ツールの設定
- Starship（プロンプト）
- Zoxide（cd拡張）
- Bat（cat拡張）
- FZF（ファジーファインダー）

## 既存設定との統合

### Neovim設定
Neovimの設定はHome Managerで管理せず、既存の設定ファイル（`~/.config/nvim/`）をそのまま使用します。Nixでは以下のみを管理：
- Neovimバイナリのインストール
- Language Serversのインストール

### Zellij設定
Zellijの設定は既存の`~/.config/zellij/`をそのまま使用します。Nixではパッケージのインストールのみ行います。

### その他のツール
- Starship: Nix設定で上書き
- Fish: Nix設定で上書き
- Git: Nix設定で上書き（必要に応じて既存設定をマイグレーション）

## トラブルシューティング

### よくある問題

1. **パッケージが見つからない**
   ```bash
   # パッケージを検索
   nix search nixpkgs <package-name>
   ```

2. **設定の適用に失敗**
   ```bash
   # 詳細なエラー情報を表示
   home-manager switch --show-trace -v
   ```

3. **古い設定との競合**
   ```bash
   # Home Manager設定をリセット
   home-manager expire-generations 0
   ```

### ログの確認

```bash
# Home Managerのログを確認
journalctl --user -u home-manager-<username>.service
```

## 設定の更新

### パッケージの更新

```bash
# チャンネルを更新
nix-channel --update

# 設定を再適用
home-manager switch
```

### 設定ファイルの変更

1. 設定ファイルを編集
2. `home-manager switch`で適用
3. 必要に応じてシェルを再起動

### 新しいパッケージの追加

1. `packages.nix`にパッケージを追加
2. `home-manager switch`で適用

## バックアップとリストア

### 設定のバックアップ

```bash
# 現在の世代を確認
home-manager generations

# 設定ファイルをバックアップ
cp -r ~/.config/home-manager ~/backup-home-manager-$(date +%Y%m%d)
```

### 前の世代への復元

```bash
# 利用可能な世代を確認
home-manager generations

# 特定の世代に戻す
/nix/store/<path-to-generation>/activate
```

## カスタマイズ

### 個人用設定の追加

1. 新しい`.nix`ファイルを作成
2. `home.nix`の`imports`に追加
3. `home-manager switch`で適用

### 既存設定との併用

- Nixで管理したくない設定は従来通り個別ファイルで管理
- 必要に応じて段階的にNixに移行

## 参考リンク

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nixpkgs Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)