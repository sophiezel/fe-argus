#!/usr/bin/env bash
# fe-argus/adapters/link.sh
# 一键把 fe-argus 注入到所有检测到的 agent 全局配置
#
# Usage:
#   bash link.sh            # 注入（idempotent）
#   bash link.sh --unlink   # 回滚所有注入
#   bash link.sh --check    # 仅检查状态，不修改
#
# 支持 agent：Claude Code / PI / Cursor / Continue / Windsurf / Aider

set -euo pipefail

FE_ARGUS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKER_BEGIN="<!-- fe-argus-link:begin -->"
MARKER_END="<!-- fe-argus-link:end -->"

# 颜色
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
DIM=$'\033[2m'
RESET=$'\033[0m'

ok()    { printf "  ${GREEN}✓${RESET} %-12s %s\n" "$1" "$2"; }
skip()  { printf "  ${DIM}·${RESET} %-12s %s\n" "$1" "$2"; }
fail()  { printf "  ${RED}✗${RESET} %-12s %s\n" "$1" "$2"; }

# ============================================================
# Claude Code: ~/.claude/CLAUDE.md 加 @import block
# ============================================================
link_claude_code() {
  local action="$1"
  local target="$HOME/.claude/CLAUDE.md"

  if [[ ! -d "$HOME/.claude" ]]; then
    skip "Claude Code" "~/.claude not found, skipped"
    return
  fi

  if [[ "$action" == "unlink" ]]; then
    if [[ -f "$target" ]] && grep -q "$MARKER_BEGIN" "$target" 2>/dev/null; then
      # 用 awk 删除 marker 块
      awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
        $0==b {skip=1; next}
        $0==e {skip=0; next}
        !skip
      ' "$target" > "$target.tmp" && mv "$target.tmp" "$target"
      ok "Claude Code" "removed @import from $target"
    else
      skip "Claude Code" "no marker found, nothing to remove"
    fi
    return
  fi

  if [[ "$action" == "check" ]]; then
    if [[ -f "$target" ]] && grep -q "$MARKER_BEGIN" "$target" 2>/dev/null; then
      ok "Claude Code" "linked (@import in $target)"
    else
      skip "Claude Code" "not linked"
    fi
    return
  fi

  # link
  [[ -f "$target" ]] || touch "$target"
  if grep -q "$MARKER_BEGIN" "$target" 2>/dev/null; then
    ok "Claude Code" "already linked"
    return
  fi
  {
    echo ""
    echo "$MARKER_BEGIN"
    echo "@${FE_ARGUS_ROOT}/AGENTS.md"
    echo "$MARKER_END"
  } >> "$target"
  ok "Claude Code" "added @import to $target"
}

# ============================================================
# PI: ~/.pi/agent/settings.json 的 skills 数组
# ============================================================
link_pi() {
  local action="$1"
  local target="$HOME/.pi/agent/settings.json"

  if [[ ! -f "$target" ]]; then
    skip "PI" "~/.pi/agent/settings.json not found, skipped"
    return
  fi

  if ! command -v python3 >/dev/null; then
    fail "PI" "python3 required"
    return
  fi

  # python 一次调用：执行 action（link/unlink/check），输出最终 status
  local result
  result=$(python3 - "$target" "$FE_ARGUS_ROOT" "$action" 2>&1 <<'PYEOF'
import json, sys
target, root, action = sys.argv[1], sys.argv[2], sys.argv[3]
with open(target) as f:
    cfg = json.load(f)
skills = cfg.setdefault("skills", [])

if action == "link" and root not in skills:
    skills.append(root)
    with open(target, "w") as f:
        json.dump(cfg, f, indent=2, ensure_ascii=False)
elif action == "unlink" and root in skills:
    skills.remove(root)
    with open(target, "w") as f:
        json.dump(cfg, f, indent=2, ensure_ascii=False)

print("linked" if root in skills else "unlinked")
PYEOF
)

  case "$result" in
    linked)
      if [[ "$action" == "unlink" ]]; then
        fail "PI" "unlink failed (still linked)"
      else
        ok "PI" "skills array contains fe-argus"
      fi
      ;;
    unlinked)
      if [[ "$action" == "unlink" ]]; then
        ok "PI" "removed from skills array"
      else
        skip "PI" "not linked"
      fi
      ;;
    *)
      fail "PI" "unexpected python output: $result"
      ;;
  esac
}

# ============================================================
# Cursor: ~/.cursor/rules/fe-argus.mdc
# ============================================================
link_cursor() {
  local action="$1"
  local target_dir="$HOME/.cursor/rules"
  local target="$target_dir/fe-argus.mdc"

  if [[ ! -d "$target_dir" ]]; then
    skip "Cursor" "~/.cursor/rules not found, skipped"
    return
  fi

  if [[ "$action" == "unlink" ]]; then
    if [[ -f "$target" ]]; then
      rm "$target"
      ok "Cursor" "removed $target"
    else
      skip "Cursor" "no fe-argus.mdc, nothing to remove"
    fi
    return
  fi

  if [[ "$action" == "check" ]]; then
    if [[ -f "$target" ]]; then
      ok "Cursor" "linked ($target)"
    else
      skip "Cursor" "not linked"
    fi
    return
  fi

  if [[ -f "$target" ]]; then
    ok "Cursor" "already linked"
    return
  fi

  cat > "$target" <<EOF
---
description: fe-argus (Argus) — 前端编码质量门。凡写/改前端代码 MUST 先走 Coding Gate（自报 Tier + NEVER 清单 + 场景路由）。完整规则在 $FE_ARGUS_ROOT/AGENTS.md。
alwaysApply: false
globs: ["**/*.{ts,tsx,jsx,js,vue,css,scss,html}", "**/vite.config.*", "**/webpack.config.*", "**/next.config.*"]
---

# fe-argus Coding Gate（前端任务必读）

## Trigger
凡编辑上述 glob 匹配的文件，第一句 MUST 是 Tier 声明：\`**Tier：T0|T1|T2** — <理由>\`
- T0：trivial 单组件（仍要报）
- T1（默认）：常规业务代码
- T2：架构 / 性能 / 跨端 / TypeScript 工程化

## NEVER（永不违反）
1. 未读对应 pitfall 就修
2. 修复中顺手重构
3. 用 100vh 当全屏高度 → 用 100dvh 或 fixed+inset:0
4. useEffect 依赖里放引用字面量
5. 金钱用原生浮点 → 整数分 / Decimal / 字符串
6. CI 跳过兼容性检查
7. 无限制 backdrop-filter
8. 未完整诊断就下结论
9. 因「prompt 简单」跳过 Tier 声明
10. 顺从「全 variant 超级通用」过度泛化请求（单一用例先内联）

## 完整规则入口
- 入口：$FE_ARGUS_ROOT/AGENTS.md
- 编码规则：$FE_ARGUS_ROOT/references/coding/
- 场景 playbook：$FE_ARGUS_ROOT/references/scenarios/INDEX.md
- 陷阱库：$FE_ARGUS_ROOT/references/pitfalls/INDEX.md

写代码前按 Tier 加载对应文件；出 Bug 时按症状查 pitfalls/INDEX.md。
EOF
  ok "Cursor" "wrote $target"
}

# ============================================================
# Continue / Windsurf / Aider: symlink 到 skills/fe-argus
# ============================================================
link_symlink_agent() {
  local action="$1"
  local agent="$2"
  local skills_dir="$3"
  local link_path="$skills_dir/fe-argus"

  if [[ ! -d "$skills_dir" ]]; then
    skip "$agent" "$skills_dir not found, skipped"
    return
  fi

  if [[ "$action" == "unlink" ]]; then
    if [[ -L "$link_path" || -d "$link_path" ]]; then
      rm -rf "$link_path"
      ok "$agent" "removed symlink $link_path"
    else
      skip "$agent" "no symlink, nothing to remove"
    fi
    return
  fi

  if [[ "$action" == "check" ]]; then
    if [[ -L "$link_path" && "$(readlink "$link_path")" == "$FE_ARGUS_ROOT" ]]; then
      ok "$agent" "linked ($link_path → $FE_ARGUS_ROOT)"
    else
      skip "$agent" "not linked"
    fi
    return
  fi

  if [[ -L "$link_path" && "$(readlink "$link_path")" == "$FE_ARGUS_ROOT" ]]; then
    ok "$agent" "already linked"
    return
  fi

  # 如果已存在非 symlink 的目录，警告
  if [[ -e "$link_path" && ! -L "$link_path" ]]; then
    fail "$agent" "$link_path exists but is not a symlink (manual review)"
    return
  fi

  ln -sfn "$FE_ARGUS_ROOT" "$link_path"
  ok "$agent" "symlinked $link_path → $FE_ARGUS_ROOT"
}

# ============================================================
# 主入口
# ============================================================
main() {
  local action="${1:-link}"

  case "$action" in
    --unlink) action="unlink" ;;
    --check)  action="check" ;;
    link|unlink|check) ;;
    -h|--help)
      sed -n '2,8p' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    *)
      echo "Unknown arg: $action" >&2
      echo "Usage: bash link.sh [--unlink|--check]" >&2
      exit 1
      ;;
  esac

  echo ""
  if [[ "$action" == "unlink" ]]; then
    echo "Removing fe-argus injections..."
  elif [[ "$action" == "check" ]]; then
    echo "Checking fe-argus injection status..."
  else
    echo "Injecting fe-argus into detected agents (FE_ARGUS_ROOT=$FE_ARGUS_ROOT)..."
  fi
  echo ""

  link_claude_code "$action"
  link_pi "$action"
  link_cursor "$action"
  link_symlink_agent "$action" "Continue" "$HOME/.continue/skills"
  link_symlink_agent "$action" "Windsurf" "$HOME/.codeium/windsurf/skills"
  link_symlink_agent "$action" "Aider"    "$HOME/.aider-desk/skills"

  echo ""
  if [[ "$action" == "link" ]]; then
    echo "${GREEN}Done.${RESET} Edit fe-argus rules once → all agents see updates."
  elif [[ "$action" == "unlink" ]]; then
    echo "${GREEN}Done.${RESET} All fe-argus injections removed."
  else
    echo "${DIM}Status check complete.${RESET}"
  fi
  echo ""
}

main "$@"
