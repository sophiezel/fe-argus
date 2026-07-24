#!/usr/bin/env bash
# fe-argus — 一键安装脚本
#
# 用法 1（已 clone 仓库，开发/本地使用）:
#   git clone <repo> && cd fe-argus && bash install.sh
#
# 用法 2（curl 一键安装到 ~/.agents/skills/fe-argus）:
#   curl -fsSL https://raw.githubusercontent.com/sophiezel/fe-argus/main/install.sh | bash
#
# 用法 3（卸载）:
#   bash install.sh --uninstall
#
# 环境变量:
#   FE_ARGUS_REPO    git 仓库地址（默认 HTTPS，可覆盖为 SSH: git@github.com:sophiezel/fe-argus.git）
#   FE_ARGUS_BRANCH  分支名（默认 main）
#   FE_ARGUS_DIR     安装目录（默认 ~/.agents/skills/fe-argus）

set -euo pipefail

# 默认配置（用户可覆盖）
DEFAULT_INSTALL_DIR="$HOME/.agents/skills/fe-argus"
REMOTE_REPO="${FE_ARGUS_REPO:-https://github.com/sophiezel/fe-argus.git}"
BRANCH="${FE_ARGUS_BRANCH:-main}"

# 颜色
if [[ -t 1 ]]; then
  GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'
  DIM=$'\033[2m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
else
  GREEN=""; YELLOW=""; RED=""; DIM=""; BOLD=""; RESET=""
fi

info()  { printf "${BOLD}==>${RESET} %s\n" "$*"; }
ok()    { printf "  ${GREEN}✓${RESET} %s\n" "$*"; }
warn()  { printf "  ${YELLOW}!${RESET} %s\n" "$*"; }
err()   { printf "  ${RED}✗${RESET} %s\n" "$*" >&2; }
die()   { err "$*"; exit 1; }

# ============================================================
# 依赖检查
# ============================================================
check_deps() {
  info "Checking dependencies..."

  command -v bash >/dev/null || die "bash required"
  ok "bash $(bash --version | head -1 | awk '{print $4}' | tr -d '()')"

  command -v python3 >/dev/null \
    || die "python3 required (used by PI settings.json injection)"
  ok "python3 $(python3 --version 2>&1 | awk '{print $2}')"

  command -v git >/dev/null \
    || die "git required (curl install mode)"
  ok "git $(git --version | awk '{print $3}')"
}

# ============================================================
# 决定 FE_ARGUS_ROOT（local vs remote 模式）
# ============================================================
resolve_root() {
  local script_dir=""
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
  fi

  if [[ -n "$script_dir" \
        && -f "$script_dir/SKILL.md" \
        && -f "$script_dir/adapters/link.sh" ]]; then
    FE_ARGUS_ROOT="$script_dir"
    INSTALL_MODE="local"
  else
    FE_ARGUS_ROOT="${FE_ARGUS_DIR:-$DEFAULT_INSTALL_DIR}"
    INSTALL_MODE="remote"
  fi
}

# ============================================================
# 安装 fe-argus 本体（仅 remote 模式需要）
# ============================================================
install_core() {
  if [[ "$INSTALL_MODE" == "local" ]]; then
    info "Using local fe-argus at ${DIM}$FE_ARGUS_ROOT${RESET}"
    return
  fi

  if [[ "$REMOTE_REPO" == *"your-org"* || "$REMOTE_REPO" == *"EXAMPLE"* ]]; then
    die "REMOTE_REPO is placeholder. Set FE_ARGUS_REPO env var or use local install."
  fi

  info "Installing fe-argus to ${DIM}$FE_ARGUS_ROOT${RESET} (branch=$BRANCH)..."

  if [[ -d "$FE_ARGUS_ROOT/.git" ]]; then
    warn "$FE_ARGUS_ROOT exists, pulling latest..."
    git -C "$FE_ARGUS_ROOT" fetch origin "$BRANCH"
    git -C "$FE_ARGUS_ROOT" checkout "$BRANCH"
    git -C "$FE_ARGUS_ROOT" reset --hard "origin/$BRANCH"
    ok "updated to origin/$BRANCH"
  elif [[ -e "$FE_ARGUS_ROOT" ]]; then
    die "$FE_ARGUS_ROOT exists but is not a git repo. Remove it or set FE_ARGUS_DIR."
  else
    mkdir -p "$(dirname "$FE_ARGUS_ROOT")"
    git clone --depth 1 -b "$BRANCH" "$REMOTE_REPO" "$FE_ARGUS_ROOT"
    ok "cloned to $FE_ARGUS_ROOT"
  fi
}

# ============================================================
# 跑 link.sh 注入到所有 agent
# ============================================================
inject_into_agents() {
  info "Injecting into detected agents..."
  bash "$FE_ARGUS_ROOT/adapters/link.sh"
}

# ============================================================
# 卸载
# ============================================================
do_uninstall() {
  info "Uninstalling fe-argus..."

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local link_sh="$script_dir/adapters/link.sh"

  if [[ -f "$link_sh" ]]; then
    bash "$link_sh" --unlink
  else
    warn "link.sh not found at $link_sh, skipping agent cleanup"
  fi

  # 仅当脚本在默认安装目录里（curl 模式安装）时才删整个目录；
  # local clone 模式不删（用户自己的 git 仓库）
  if [[ "$script_dir" == "$DEFAULT_INSTALL_DIR" && -d "$script_dir" ]]; then
    warn "Removing install dir $script_dir"
    rm -rf "$script_dir"
    ok "removed $script_dir"
  else
    ok "kept local clone at $script_dir (remove manually if no longer needed)"
  fi

  echo ""
  info "${GREEN}fe-argus uninstalled.${RESET}"
}

# ============================================================
# 打印下一步
# ============================================================
print_next_steps() {
  cat <<EOF

${BOLD}Next steps${RESET}

  1. ${DIM}Restart any running agents${RESET} (Claude Code / Cursor / PI / etc.)
     so they reload global config.

  2. ${DIM}Verify the install${RESET}:
     ${BOLD}cd $FE_ARGUS_ROOT && skill-up run evals/eval.yaml${RESET}

  3. ${DIM}Trigger it${RESET} — in any agent, ask for any frontend task:
     ${DIM}"implement a React search box"${RESET}
     You should see: ${BOLD}Tier：T1${RESET} ... at the top of the response.

  4. ${DIM}Edit rules once${RESET}, all agents see updates:
     ${FE_ARGUS_ROOT}/references/

${BOLD}Uninstall${RESET}: bash $FE_ARGUS_ROOT/install.sh --uninstall
${BOLD}Docs${RESET}:    $FE_ARGUS_ROOT/README.md
EOF
}

# ============================================================
# 主入口
# ============================================================
main() {
  local action="${1:-install}"

  case "$action" in
    --uninstall|-u)
      echo ""
      echo "${BOLD}fe-argus uninstaller${RESET}"
      echo ""
      do_uninstall
      exit 0
      ;;
    --help|-h)
      sed -n '2,20p' "${BASH_SOURCE[0]}"
      exit 0
      ;;
    install|--install) ;;
    *)
      die "Unknown action: $action. Try --help."
      ;;
  esac

  echo ""
  echo "${BOLD}fe-argus installer${RESET} ${DIM}— 前端编码质量门（跨 agent）${RESET}"
  echo ""

  check_deps
  resolve_root
  install_core
  inject_into_agents

  echo ""
  info "${GREEN}Installed.${RESET} fe-argus at ${BOLD}$FE_ARGUS_ROOT${RESET}"
  print_next_steps
}

main "$@"
