{ lib, pkgs, ... }:

let
  # Matt Pocock の Agent Skills (https://github.com/mattpocock/skills)
  # plugin version 1.2.3 (2026-09-18) に固定。更新時は rev と hash を差し替える:
  #   nix-prefetch-url --unpack https://github.com/mattpocock/skills/archive/<rev>.tar.gz
  #   nix hash to-sri --type sha256 <出力>
  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "c55ee46073ed923f86ce59a5eb3b6d895095d1b7";
    hash = "sha256-L3CpIT2DeI+fUFl9fcygojtQo2DzEen69rMD1XqR1vM=";
  };

  # グローバルに配置するスキル: <スキル名> = <リポジトリ内のスキルディレクトリ>
  # grill-me はユーザー呼び出し専用 (/grill-me, $grill-me) で、中身は grilling を呼ぶ薄いラッパー。
  # grilling は "grill" 系のトリガー語からモデルが自動発動できる本体。両方入れて初めて揃う。
  skills = {
    grilling = "skills/productivity/grilling";
    grill-me = "skills/productivity/grill-me";
    # grill-with-docs もユーザー呼び出し専用 (/grill-with-docs, $grill-with-docs) で、
    # grilling と domain-modeling の 2 つを呼ぶ薄いラッパー。domain-modeling が無いと
    # CONTEXT.md / ADR が書かれないので必ずセットで入れる。
    grill-with-docs = "skills/engineering/grill-with-docs";
    domain-modeling = "skills/engineering/domain-modeling";
  };

  # 各エージェントがユーザースコープのスキルを探すディレクトリ。
  #   Claude Code: ~/.claude/skills/<name>/SKILL.md
  #   Codex:       ~/.codex/skills/<name>/SKILL.md (+ agents/openai.yaml)
  skillDirs = [
    ".claude/skills"
    ".codex/skills"
  ];

  linksFor = dir:
    lib.mapAttrs' (name: path:
      lib.nameValuePair "${dir}/${name}" {
        source = "${mattpocockSkills}/${path}";
      }
    ) skills;
in
{
  home.file = lib.foldl' (acc: dir: acc // linksFor dir) { } skillDirs;
}
