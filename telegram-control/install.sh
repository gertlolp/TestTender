#!/usr/bin/env bash
# =============================================================================
#  Telegram Control for Claude Code — установщик (запускать ВНУТРИ WSL Ubuntu)
#
#  Что делает:
#   1. Ставит системные пакеты (git, curl, python3.11, ffmpeg и т.п.)
#   2. Ставит Node.js + Claude Code CLI
#   3. Ставит uv (менеджер Python) и Poetry
#   4. Клонирует бота RichardAtCT/claude-code-telegram (v1.3.0)
#   5. Готовит .env из шаблона
#
#  Использование (в WSL):
#     bash install.sh
# =============================================================================
set -euo pipefail

BOT_DIR="${HOME}/claude-code-telegram"
BOT_REPO="https://github.com/RichardAtCT/claude-code-telegram.git"
BOT_TAG="v1.3.0"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

say() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }

# --- 1. Системные пакеты -----------------------------------------------------
say "Обновляю apt и ставлю системные пакеты..."
sudo apt-get update -y
sudo apt-get install -y \
  git curl build-essential \
  python3 python3-pip python3-venv \
  ffmpeg                            `# для монтажа/обработки видео` \
  unzip

# Python 3.11+ check
PYV=$(python3 -c 'import sys;print(f"{sys.version_info.major}.{sys.version_info.minor}")')
say "Python версия: ${PYV} (нужно 3.11+)"

# --- 2. Node.js + Claude Code CLI -------------------------------------------
if ! command -v node >/dev/null 2>&1; then
  say "Ставлю Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
say "Node: $(node -v) | npm: $(npm -v)"

if ! command -v claude >/dev/null 2>&1; then
  say "Ставлю Claude Code CLI..."
  sudo npm install -g @anthropic-ai/claude-code
fi
say "Claude Code: $(claude --version 2>/dev/null || echo 'установлен')"

# --- 3. uv + Poetry ----------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  say "Ставлю uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! command -v poetry >/dev/null 2>&1; then
  say "Ставлю Poetry..."
  curl -sSL https://install.python-poetry.org | python3 -
  export PATH="${HOME}/.local/bin:${PATH}"
fi

# --- 4. Клонирую бота --------------------------------------------------------
if [ -d "${BOT_DIR}/.git" ]; then
  say "Бот уже склонирован в ${BOT_DIR}, обновляю..."
  git -C "${BOT_DIR}" fetch --tags --quiet
  git -C "${BOT_DIR}" checkout "${BOT_TAG}" --quiet || true
else
  say "Клонирую бота в ${BOT_DIR}..."
  git clone --branch "${BOT_TAG}" --depth 1 "${BOT_REPO}" "${BOT_DIR}"
fi

# --- 5. Зависимости бота -----------------------------------------------------
say "Ставлю зависимости бота (make dev / poetry)..."
cd "${BOT_DIR}"
if command -v make >/dev/null 2>&1 && grep -q "^dev:" Makefile 2>/dev/null; then
  make dev || poetry install
else
  poetry install
fi

# --- 6. .env -----------------------------------------------------------------
if [ ! -f "${BOT_DIR}/.env" ]; then
  if [ -f "${KIT_DIR}/.env.example" ]; then
    cp "${KIT_DIR}/.env.example" "${BOT_DIR}/.env"
  elif [ -f "${BOT_DIR}/.env.example" ]; then
    cp "${BOT_DIR}/.env.example" "${BOT_DIR}/.env"
  fi
  say ".env создан в ${BOT_DIR}/.env — ОТРЕДАКТИРУЙ его (токен, user_id, папка)!"
else
  say ".env уже существует — не трогаю."
fi

cat <<EOF

\033[1;32m================ ГОТОВО ================\033[0m

Дальше — 3 шага вручную:

  1) Авторизуй Claude Code (если идёшь через подписку, не через API-ключ):
       claude auth login

  2) Отредактируй конфиг:
       nano ${BOT_DIR}/.env
     Заполни: TELEGRAM_BOT_TOKEN, TELEGRAM_BOT_USERNAME, ALLOWED_USERS, APPROVED_DIRECTORY

  3) Запусти бота:
       cd ${BOT_DIR} && make run

Токен бота:    @BotFather в Telegram
Свой user_id:  @userinfobot в Telegram

EOF
