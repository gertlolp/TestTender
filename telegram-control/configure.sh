#!/usr/bin/env bash
# =============================================================================
#  Интерактивная настройка + запуск бота (запускать в WSL ПОСЛЕ install.sh)
#
#  Спросит токен, username, user_id и папку проектов, безопасно запишет .env
#  (chmod 600, токен в файле — не в истории терминала) и предложит запустить.
#
#  Использование (в WSL):
#     bash configure.sh
# =============================================================================
set -euo pipefail

BOT_DIR="${HOME}/claude-code-telegram"
ENV_FILE="${BOT_DIR}/.env"

say()  { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m%s\033[0m\n" "$*"; }

if [ ! -d "${BOT_DIR}" ]; then
  warn "Не найден ${BOT_DIR}. Сначала запусти install.sh."
  exit 1
fi

say "Настройка Telegram-бота для Claude Code"
echo "Значения в скобках — по умолчанию, жми Enter чтобы принять."
echo

# --- Токен (скрытый ввод, чтобы не светить в истории) ---
warn "ВАЖНО: если токен уже светился где-то — сделай /revoke у @BotFather и вставь новый."
read -rsp "Токен бота (TELEGRAM_BOT_TOKEN): " TOKEN; echo
while [ -z "${TOKEN}" ]; do
  read -rsp "Токен не может быть пустым. Введи ещё раз: " TOKEN; echo
done

# --- Username ---
read -rp "Username бота без @ [Claudebotik_MY_BOT]: " USERNAME
USERNAME="${USERNAME:-Claudebotik_MY_BOT}"

# --- user_id ---
read -rp "Твой Telegram user_id [1149630350]: " USERID
USERID="${USERID:-1149630350}"

# --- Папка проектов ---
DEFAULT_DIR="/mnt/c/Users/$(whoami)/projects"
read -rp "Папка с проектами (APPROVED_DIRECTORY) [${DEFAULT_DIR}]: " APPDIR
APPDIR="${APPDIR:-${DEFAULT_DIR}}"
mkdir -p "${APPDIR}" 2>/dev/null || warn "Не смог создать ${APPDIR} — проверь путь вручную."

# --- Аутентификация ---
echo
echo "Аутентификация Claude:"
echo "  1) Подписка Claude (рекомендую) — сделаешь 'claude auth login'"
echo "  2) Anthropic API-ключ (sk-ant-...)"
read -rp "Выбор [1]: " AUTH; AUTH="${AUTH:-1}"
APIKEY=""
if [ "${AUTH}" = "2" ]; then
  read -rsp "ANTHROPIC_API_KEY: " APIKEY; echo
fi

# --- Запись .env ---
say "Пишу ${ENV_FILE}"
{
  echo "TELEGRAM_BOT_TOKEN=${TOKEN}"
  echo "TELEGRAM_BOT_USERNAME=${USERNAME}"
  echo "ALLOWED_USERS=${USERID}"
  echo "APPROVED_DIRECTORY=${APPDIR}"
  [ -n "${APIKEY}" ] && echo "ANTHROPIC_API_KEY=${APIKEY}"
  echo "CLAUDE_TIMEOUT_SECONDS=600"
  echo "AGENTIC_MODE=true"
  echo "VERBOSE_LEVEL=1"
} > "${ENV_FILE}"
chmod 600 "${ENV_FILE}"
say ".env записан и защищён (chmod 600)."

# --- claude auth login при подписке ---
if [ "${AUTH}" != "2" ]; then
  echo
  read -rp "Запустить 'claude auth login' сейчас? [Y/n]: " DOAUTH
  if [[ ! "${DOAUTH}" =~ ^[Nn] ]]; then
    claude auth login || warn "Авторизация не завершилась — можно повторить позже: claude auth login"
  fi
fi

# --- Запуск ---
echo
read -rp "Запустить бота сейчас? [Y/n]: " DORUN
if [[ ! "${DORUN}" =~ ^[Nn] ]]; then
  say "Запускаю бота. Останов — Ctrl+C. Открой бота в Telegram и напиши ему."
  cd "${BOT_DIR}" && make run
else
  echo
  say "Готово. Когда захочешь — запусти:"
  echo "    cd ${BOT_DIR} && make run"
fi
