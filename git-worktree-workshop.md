# Git Worktree勉強会

## 目的

AIを使った並行作業ができる状態を目指す。

ついでに周辺のCLIを整えたり他の人の作業フローを知ったりして普段の作業を効率化する。

## Git Worktreeとは

### 概要

Git Worktreeは、1つのリポジトリで複数のブランチを**同時に**チェックアウトできる機能です。

```
repo/
├── main/              # メインブランチ
├── feature-a/         # feature-aブランチ
└── feature-b/         # feature-bブランチ
```

### 従来の方法との違い

**従来（ブランチ切り替え）:**
```bash
git checkout feature-a
# 作業...
git checkout feature-b  # ← 切り替えが必要
# 作業...
```

**Worktreeを使う場合:**
```bash
cd ~/repo/feature-a
# 作業...
cd ~/repo/feature-b    # ← 別ディレクトリに移動するだけ
# 作業...
```

### なぜAI並行作業に便利なのか

1. **複数のAIエージェントが同時に作業可能**
   - エージェントAは`feature-a`で新機能開発
   - エージェントBは`bugfix-b`でバグ修正
   - 互いに干渉しない

2. **切り替えコストがゼロ**
   - ブランチ切り替え時のビルド待ち不要
   - ファイルの変更検知による再コンパイル不要

3. **作業コンテキストを保持**
   - 各worktreeでエディタ、ターミナルセッションを開いたまま
   - 切り替えても作業状態が消えない

## Worktree管理ツール

### gwq - Git Worktree管理ツール

**公式リポジトリ:** https://github.com/d-kuro/gwq

`ghq`のようなインターフェースでworktreeを管理できるCLIツール。

**主な機能:**
- Fuzzy Finderによる直感的なworktree選択
- worktreeの一括管理
- 命名規則の統一（`github.com/owner/repo=branch`形式）
- ghqと統合した検索

**対応コマンド:**
```bash
gwq add      # 新しいworktreeを作成
gwq cd       # worktreeに移動（新しいシェルを起動）
gwq list     # worktreeの一覧表示
gwq remove   # worktreeを削除
gwq status   # 全worktreeのgit statusを表示
gwq get      # worktreeのパスを取得
```

## 実際の操作

### 1. gwqをインストール

#### Homebrewの場合
```bash
brew install d-kuro/tap/gwq
```

#### Goの場合
```bash
go install github.com/d-kuro/gwq/cmd/gwq@latest
```

#### miseの場合
```bash
mise use -g go:github.com/d-kuro/gwq/cmd/gwq
```

### 2. gwqの設定

`~/.config/gwq/config.toml`を作成:

```toml
[naming]
template = '{{.Host}}/{{.Owner}}/{{.Repository}}={{.Branch}}'

[worktree]
basedir = '~/ghq'  # ghqと統合する場合
```

### 3. Worktreeを作る

#### パターン1: リポジトリがまだない場合
```bash
# リポジトリをクローン + worktree作成
gwq add github.com/username/repo feature-branch
```

#### パターン2: 既存リポジトリにworktreeを追加
```bash
cd ~/ghq/github.com/username/repo
gwq add feature-branch
```

#### パターン3: リモートブランチからworktreeを作成
```bash
gwq add origin/feature-branch
```

**実行後のディレクトリ構造:**
```
~/ghq/
└── github.com/
    └── username/
        └── repo=feature-branch/
```

### 4. Worktreeに移動する

#### Fuzzy Finderで選択
```bash
gwq cd
# → インタラクティブにworktreeを選択
```

#### パターン指定で移動
```bash
gwq cd feature
# → "feature"を含むworktreeに移動
```

#### 直接パスを取得
```bash
cd $(gwq get feature)
```

### 5. Worktreeで作業する

移動後は通常のgitリポジトリと同じように作業できます:

```bash
# feature-branchのworktreeで作業
git status
git add .
git commit -m "Add feature"
git push origin feature-branch

# 別のworktreeに移動
gwq cd bugfix
# → すぐに別の作業に切り替え可能
```

### 6. Worktreeの状態確認

#### 全worktreeのステータスを確認
```bash
gwq status
```

出力例:
```
github.com/user/repo=main
  On branch main
  nothing to commit, working tree clean

github.com/user/repo=feature-a
  On branch feature-a
  Changes not staged for commit:
    modified: src/main.rs
```

#### Worktree一覧
```bash
gwq list
```

### 7. Worktreeの削除

```bash
gwq remove feature-branch
```

または
```bash
gwq cd  # Fuzzy Finderで選択 → 削除オプション
```

## Windowを分割する

### zellijをインストール

#### Homebrewの場合
```bash
brew install zellij
```

#### Nixの場合
```nix
# ~/.config/home-manager/packages.nix
home.packages = with pkgs; [
  zellij
];
```

### zellijの基本操作

**このリポジトリの設定では `Ctrl+q` がプレフィックスキー**

#### ペイン操作
```
Ctrl+q → s    # 水平分割
Ctrl+q → v    # 垂直分割
Ctrl+q → x    # ペインを閉じる
Ctrl+q → z    # ペインをズーム（最大化/元に戻す）

Ctrl+q → h/j/k/l  # vim風にペイン間移動
```

#### タブ操作
```
Ctrl+q → c    # 新しいタブ作成
Ctrl+q → n    # 次のタブ
Ctrl+q → p    # 前のタブ
Ctrl+q → X    # タブを閉じる
Ctrl+q → r    # タブ名変更
Ctrl+q → 1-9  # タブ番号で移動
```

#### セッション管理
```
Ctrl+q → d    # セッションをデタッチ
zellij attach # セッションに再接続
zellij ls     # セッション一覧
```

## AI並行作業の実践例

### シナリオ: 複数の機能を並行開発

#### 1. Worktreeのセットアップ
```bash
# メイン機能
gwq add feature-auth

# バグ修正
gwq add bugfix-login

# リファクタリング
gwq add refactor-api
```

#### 2. Zellijでワークスペースを構築

**ターミナル1:** zellijを起動
```bash
zellij
```

**レイアウト例:**
```
┌─────────────────┬─────────────────┐
│  feature-auth   │  bugfix-login   │
│                 │                 │
├─────────────────┴─────────────────┤
│         refactor-api              │
└───────────────────────────────────┘
```

**セットアップ手順:**
```bash
# 最初のペインでfeature-authに移動
gwq cd feature-auth

# 垂直分割して、新しいペインでbugfix-loginに移動
Ctrl+q → v
gwq cd bugfix-login

# 水平分割して、新しいペインでrefactor-apiに移動
Ctrl+q → s
gwq cd refactor-api
```

#### 3. 各ペインでAIと作業

**ペイン1 (feature-auth):**
```bash
# Claude Codeで認証機能を実装
claude "ユーザー認証機能を実装して"
```

**ペイン2 (bugfix-login):**
```bash
# 別のAIエージェントでバグ修正
claude "ログインエラーを修正して"
```

**ペイン3 (refactor-api):**
```bash
# さらに別のエージェントでリファクタリング
claude "API層をクリーンアーキテクチャにリファクタリング"
```

#### 4. 進捗を確認

```bash
# 別のタブで全体の状況を確認
Ctrl+q → c
gwq status
```

## Tips & Best Practices

### 1. Worktreeの命名規則

**推奨:**
```
feature/user-auth      # 機能追加
bugfix/login-error     # バグ修正
refactor/api-layer     # リファクタリング
experiment/new-ui      # 実験的な変更
```

### 2. ghqとの統合

gwqの`basedir`をghqと同じにすることで、すべてのリポジトリを統一的に管理:

```bash
# ghqでクローンしたリポジトリ
ghq get github.com/user/repo

# そのリポジトリでworktreeを作成
cd $(ghq root)/github.com/user/repo
gwq add feature-branch

# ghq listとgwq listが統合される
```

### 3. Zellijのセッション管理

**プロジェクトごとにセッションを作成:**
```bash
# プロジェクトAのセッション
zellij -s project-a

# プロジェクトBのセッション
zellij -s project-b

# セッション切り替え
zellij attach project-a
```

### 4. 作業完了後のクリーンアップ

```bash
# マージ済みのworktreeを削除
gwq list | grep merged | xargs -I {} gwq remove {}

# または手動で確認しながら削除
gwq remove feature-branch
```

### 5. エディタの統合

**VS Code:**
```bash
# worktree内でVS Codeを開く
gwq cd feature-branch
code .
```

**Neovim:**
```bash
# worktreeでNeovimを開く
gwq cd feature-branch
nvim
```

## トラブルシューティング

### Q: Worktreeを削除したのにgitが認識している

**A:** Gitのworktree情報をクリーンアップ
```bash
git worktree prune
```

### Q: 同じブランチのworktreeを複数作れない

**A:** Git Worktreeの制約により、同じブランチは1つのworktreeにしかチェックアウトできません。
別のworktreeで作業したい場合は、新しいブランチを作成してください。

```bash
gwq add feature-branch-v2
```

### Q: Worktreeのディレクトリを移動したい

**A:** Gitコマンドでworktreeの場所を変更
```bash
git worktree move <old-path> <new-path>
```

### Q: Zellijのセッションが残ってしまう

**A:** セッションを削除
```bash
zellij delete-session <session-name>

# または全セッション削除
zellij delete-all-sessions
```

## 参考資料

### 公式ドキュメント
- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [gwq GitHub Repository](https://github.com/d-kuro/gwq)
- [Zellij Documentation](https://zellij.dev/documentation/)

### 関連ツール
- **ghq**: リポジトリ管理ツール
- **fzf**: Fuzzy Finder（gwqで使用）
- **lazygit**: Git TUIクライアント
- **delta**: Git diff viewer

## まとめ

### Git Worktreeのメリット
- ✅ 複数ブランチで同時作業可能
- ✅ ブランチ切り替えのコストがゼロ
- ✅ AI並行作業に最適
- ✅ コンテキストスイッチが不要

### gwqのメリット
- ✅ 直感的なworktree管理
- ✅ Fuzzy Finderで素早い移動
- ✅ ghqとの統合
- ✅ 一貫した命名規則

### Zellijのメリット
- ✅ 複数worktreeを1画面で管理
- ✅ セッション永続化
- ✅ tmux風の操作感
- ✅ マウスサポート

**これらを組み合わせることで、AIを活用した効率的な並行開発環境が実現できます！**
