#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEMINI_CONFIG_DIR="${HOME}/.gemini/config"
GLOBAL_SKILLS_DIR="${GEMINI_CONFIG_DIR}/skills"
GLOBAL_PLUGINS_DIR="${GEMINI_CONFIG_DIR}/plugins"
CLAUDE_SKILLS_DIR="${HOME}/.claude/skills"

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  H3 Colab Studio Skill & Plugin Installer${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

MODE="${1:-all}"

install_agy_skill() {
  echo -e "${YELLOW}--> Installing standalone skill to ${GLOBAL_SKILLS_DIR}/h3-colab-studio...${NC}"
  mkdir -p "${GLOBAL_SKILLS_DIR}"
  rm -rf "${GLOBAL_SKILLS_DIR}/h3-colab-studio"
  cp -R "${SCRIPT_DIR}/skills/h3-colab-studio" "${GLOBAL_SKILLS_DIR}/"
  chmod +x "${GLOBAL_SKILLS_DIR}/h3-colab-studio/scripts/stitch.sh"
  echo -e "${GREEN}✔ Antigravity standalone skill installed!${NC}"
}

install_agy_plugin() {
  echo -e "${YELLOW}--> Installing native plugin to ${GLOBAL_PLUGINS_DIR}/h3-colab-studio...${NC}"
  mkdir -p "${GLOBAL_PLUGINS_DIR}"
  rm -rf "${GLOBAL_PLUGINS_DIR}/h3-colab-studio"
  cp -R "${SCRIPT_DIR}/plugins/h3-colab-studio" "${GLOBAL_PLUGINS_DIR}/"
  chmod +x "${GLOBAL_PLUGINS_DIR}/h3-colab-studio/skills/h3-colab-studio/scripts/stitch.sh"

  if command -v agy >/dev/null 2>&1; then
    echo -e "${YELLOW}--> Validating plugin with agy CLI...${NC}"
    agy plugin validate "${GLOBAL_PLUGINS_DIR}/h3-colab-studio" --strict || true
  fi
  echo -e "${GREEN}✔ Antigravity native plugin installed!${NC}"
}

install_claude_skill() {
  echo -e "${YELLOW}--> Installing Claude Code skill to ${CLAUDE_SKILLS_DIR}/h3-colab-studio...${NC}"
  mkdir -p "${CLAUDE_SKILLS_DIR}"
  rm -rf "${CLAUDE_SKILLS_DIR}/h3-colab-studio"
  cp -R "${SCRIPT_DIR}/skills/h3-colab-studio" "${CLAUDE_SKILLS_DIR}/"
  chmod +x "${CLAUDE_SKILLS_DIR}/h3-colab-studio/scripts/stitch.sh"
  echo -e "${GREEN}✔ Claude Code skill installed!${NC}"
}

case "$MODE" in
  skills)
    install_agy_skill
    ;;
  plugins)
    install_agy_plugin
    ;;
  claude)
    install_claude_skill
    ;;
  all)
    install_agy_skill
    install_agy_plugin
    ;;
  *)
    echo "Usage: $0 [all|skills|plugins|claude]"
    exit 1
    ;;
esac

echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}=================================================${NC}"
