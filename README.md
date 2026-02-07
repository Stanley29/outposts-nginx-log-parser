# Outposts Nginx Log Parser

Проєкт для тестового завдання: парсер nginx‑логів, який конвертує їх у CSV, підтримує фільтри, сортування, автоматичний git commit/push та може запускатися в Docker або на AWS EC2.

---

## Функціонал

- Парсинг стандартного nginx access.log
- Генерація CSV з автоматичною назвою `parsed_YYYY-MM-DD.csv`
- Опції:
  - `--sort ip|time|status`
  - `--filter-status N`
  - `--git` — автоматичний git add + commit + push
- Dockerfile для контейнеризації
- Можливість запуску на AWS EC2

---

## Локальний запуск

```bash

./parser.sh --input access.log

```

## З фільтром:

```bash

./parser.sh --input access.log --filter-status 404

```

## З сортуванням:

```bash

./parser.sh --input access.log --sort status

```

## З автоматичним git push:

```bash

./parser.sh --input access.log --git

```

# Docker

## Build:

```bash

docker build -t nginx-parser .

```

## Run:

```bash

docker run -v $(pwd):/data nginx-parser --input /data/access.log --git

```

# AWS EC2

У цьому розділі будуть:

- скріншоти EC2

- запуск Docker на EC2

- результат git push з EC2

- фінальний CSV


Папка для скріншотів:

```Code

screenshots/

```

# Структура проєкту

```Code

outposts-nginx-log-parser/
├── parser.sh
├── Dockerfile
├── README.md
├── access.log
└── screenshots/

```

# Ліцензія

MIT


