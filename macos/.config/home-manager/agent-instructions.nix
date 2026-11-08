{ ... }:

# 全リポジトリ共通のエージェント向け指示（関数型プログラミング / 関数型ドメインモデリングを柱とする）。
# 同じ内容を Claude Code と Codex の両方のユーザースコープに配置する。
#   Claude Code: ~/.claude/CLAUDE.md
#   Codex:       ~/.codex/AGENTS.md
# 参照している書籍 PDF (~/.local/share/references/functional-domain-modeling.pdf) は
# 著作物のためこのリポジトリでは管理しない（各マシンに手動で配置する）。
{
  home.file.".claude/CLAUDE.md".source = ./agent-instructions/GLOBAL.md;
  home.file.".codex/AGENTS.md".source = ./agent-instructions/GLOBAL.md;
}
