# Управление Claude Code с телефона через Telegram (на своём ПК)

Гибрид: **тяжёлые задачи (монтаж, парсинг, прогон окружений) крутятся на твоём железе**,
а командуешь ты из Telegram с телефона. Бот живёт на твоём Windows-ПК, Claude Code там же
имеет доступ к локальным инструментам (ffmpeg, парсеры, твои файлы).

Используется проект: [RichardAtCT/claude-code-telegram](https://github.com/RichardAtCT/claude-code-telegram) (v1.3.0).

---

## ⚠️ Важно про безопасность

Бот фактически даёт доступ к командной строке твоего ПК. Поэтому:

- **`ALLOWED_USERS`** — только твой Telegram user_id. Без этого бот будет слушать кого угодно.
- **`APPROVED_DIRECTORY`** — ограничь папкой с проектами, а не всем диском.
- **Токен бота** — секрет. Не коммить `.env`, никому не показывай.
- Если ПК выключен — управления нет (это нормально, в этом суть «своего железа»).

---

## Шаг 0. Что понадобится

- Windows 10/11
- Аккаунт Claude (подписка) **или** Anthropic API-ключ
- Telegram

---

## Шаг 1. Установить WSL2 (Ubuntu)

Claude Code стабильнее всего работает под Linux. На Windows для этого есть WSL.

Открой **PowerShell от имени администратора** и выполни:

```powershell
wsl --install -d Ubuntu
```

Перезагрузи ПК, если попросит. После перезагрузки откроется окно Ubuntu —
придумай имя пользователя и пароль (запомни пароль, он нужен для `sudo`).

> Если WSL уже стоял: `wsl --update`, затем запусти «Ubuntu» из меню Пуск.

---

## Шаг 2. Скопировать этот комплект в WSL и запустить установщик

Внутри окна **Ubuntu (WSL)** выполни (подставь свой Windows-логин):

```bash
# Перейти в папку с этим репозиторием на диске C (пример пути)
cd /mnt/c/Users/ТВОЙ_ЛОГИН/TestTender/telegram-control

# Запустить установщик
bash install.sh
```

Скрипт сам поставит: системные пакеты, **ffmpeg**, Node.js, **Claude Code CLI**, uv, Poetry,
склонирует бота и подготовит `.env`. Это займёт несколько минут.

---

## Шаг 3. Создать Telegram-бота и узнать свой ID

1. В Telegram напиши **[@BotFather](https://t.me/botfather)** → `/newbot` → задай имя.
   Он выдаст **токен** (длинная строка) и **username** бота.
2. Напиши **[@userinfobot](https://t.me/userinfobot)** → он пришлёт твой числовой **user_id**.

---

## Шаг 4. Заполнить конфиг

```bash
nano ~/claude-code-telegram/.env
```

Заполни как минимум:

```
TELEGRAM_BOT_TOKEN=токен_от_BotFather
TELEGRAM_BOT_USERNAME=имя_бота_без_@
ALLOWED_USERS=твой_user_id
APPROVED_DIRECTORY=/mnt/c/Users/ТВОЙ_ЛОГИН/projects
```

Аутентификация — выбери одно:
- **Подписка Claude:** оставь `ANTHROPIC_API_KEY` пустым и выполни `claude auth login`.
- **API-ключ:** впиши `ANTHROPIC_API_KEY=sk-ant-...`.

Сохранить в nano: `Ctrl+O`, `Enter`, выйти `Ctrl+X`.

---

## Шаг 5. Запустить

```bash
cd ~/claude-code-telegram
make run
```

Теперь открой своего бота в Telegram и напиши ему — например:
> «зайди в проект X, запусти сборку и покажи ошибки»
> «склей видео из папки clips через ffmpeg в 1080p»
> «спарси вот эти страницы и собери в csv»

Claude выполнит это **на твоём ПК** и пришлёт результат в чат.

---

## Шаг 6 (опционально). Автозапуск, чтобы бот жил всегда

Чтобы бот стартовал сам и не зависел от открытого окна, создай systemd-сервис в WSL:

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/claude-tg.service <<'UNIT'
[Unit]
Description=Claude Code Telegram bot
After=network-online.target

[Service]
WorkingDirectory=%h/claude-code-telegram
ExecStart=/usr/bin/make run
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now claude-tg.service
# чтобы работало без активной сессии WSL:
sudo loginctl enable-linger "$USER"
```

Проверить статус/логи:

```bash
systemctl --user status claude-tg.service
journalctl --user -u claude-tg.service -f
```

> Учти: чтобы бот отвечал, **ПК должен быть включён** (можно отключить «сон» в настройках питания Windows, если нужен доступ 24/7).

---

## Если что-то не так

- `claude: command not found` → перезапусти WSL-сессию или `export PATH="$HOME/.local/bin:$PATH"`.
- Бот не отвечает → проверь, что твой `user_id` точно в `ALLOWED_USERS`, и токен без лишних пробелов.
- Видео/парсинг падает → убедись, что нужный инструмент стоит (`ffmpeg -version`, `python3 --version`).

Полная дока проекта: https://github.com/RichardAtCT/claude-code-telegram
