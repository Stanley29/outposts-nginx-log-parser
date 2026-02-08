# AWS EC2 + Docker + GitHub + Nginx Log Parser

Проєкт для тестового завдання: парсер nginx‑логів, який конвертує їх у CSV, підтримує фільтри, сортування, автоматичний git commit/push та може запускатися в Docker або на AWS EC2.

## Мета
Розгорнути робоче середовище на AWS EC2, встановити Docker, зібрати Docker‑образ із парсером логів Nginx, запустити контейнер, автоматично згенерувати CSV та виконати git push у GitHub зсередини Docker‑контейнера.
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
# Структура проєкту

```Code

outposts-nginx-log-parser/
├── parser.sh
├── Dockerfile
├── README.md
├── access.log
└── screenshots/

```
---

### Локальний запуск

```bash

./parser.sh --input access.log

```

### З фільтром:

```bash

./parser.sh --input access.log --filter-status 404

```

### З сортуванням:

```bash

./parser.sh --input access.log --sort status

```

### З автоматичним git push:

```bash

./parser.sh --input access.log --git

```

## Docker

### Build:

```bash

docker build -t nginx-parser .

```

### Run:

```bash

docker run -v $(pwd):/data nginx-parser --input /data/access.log --git

```

## AWS EC2

У цьому розділі описані кроки по тестуванню парсера на AWS EC2

### 1. Створення EC2 інстансу
![EC2 launch](./00_ec2_launch_instance.jpg)

Створено EC2 instance (Ubuntu), налаштовано security group, SSH‑доступ та запущено машину.

### 2. Підключення до EC2 через SSH
![SSH connected](./02_ec2_ssh_connected.jpg)

Підключення командою:

``` Code
ssh -i mykey.pem ubuntu@<EC2-IP>

```

### 3. Встановлення Docker
![Docker hello world](./03_docker_hello_world.jpg)

Команди:

``` Code
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu

```

Перевірка:

``` Code
docker run hello-world

```

### 4. Встановлення Git
![Git installed](./04_git_installed.jpg)

``` Code
sudo apt install git -y
git --version

```

### 5. Генерація SSH‑ключа для GitHub
![GitHub SSH key](./05_github_ssh_key.jpg)

``` Code
ssh-keygen -t rsa -b 4096 -C "sergii@example.com"
cat ~/.ssh/id_rsa.pub

```


Додавання ключа в GitHub → Settings → SSH keys
![GitHub SSH key added](./05_github_ssh_key_github.jpg)

### 6. Клонування репозиторію
![Repo cloned](./06_repo_cloned.jpg)

``` Code
git clone git@github.com:Stanley29/outposts-nginx-log-parser.git
cd outposts-nginx-log-parser

```

### 7. Огляд вмісту репозиторію
![Repo contents](./07_repo_contents.jpg)

Файли:

- Dockerfile

- parser.sh

- access.log

- інші допоміжні файли

### 8. Збірка Docker‑образу
![Docker build](./08_docker_build.jpg)

``` Code
docker build -t nginx-parser .

```

### 9. Запуск Docker з автоматичним git push
![Docker run with git push](./09_docker_run_git_push.jpg)

Це найскладніший етап, бо git всередині контейнера блокує доступ до репозиторію через політику безпеки.

Проблеми, які виникли:
❌ Проблема 1:
fatal: detected dubious ownership in repository at '/app'

Git блокує роботу, бо:

- контейнер працює як root

- каталог /app змонтований з хоста і належить ubuntu

- Git вважає це небезпечним

✔️ Рішення:
Додати safe.directory  всередині контейнера:

```Code
git config --global --add safe.directory /app

```

❌ Проблема 2:
Git не знає user.name  та user.email:

``` Code
Author identity unknown

```

✔️ Рішення:
```Code
git config --global user.email "sergii@example.com"
git config --global user.name "Sergii"

```

❌ Проблема 3:
Потрібно передати SSH‑ключі в контейнер, але не копіювати їх у Dockerfile (небезпечно).

✔️ Рішення:
Монтувати ключі:

``` Code
-v ~/.ssh:/root/.ssh

```

Фінальна робоча команда:
```Code
docker run \
  -v $(pwd):/app \
  -v ~/.ssh:/root/.ssh \
  --entrypoint bash \
  nginx-parser \
  -c "git config --global user.email 'sergii@example.com' && git config --global user.name 'Sergii' && git config --global --add safe.directory /app && ./parser.sh --input /app/access.log --git"

```

Результат:

- CSV створено

- git add → OK

- git commit → OK

- git push → OK

### 10. Результат у GitHub
![GitHub commit result](./10_github_commit_result.jpg)

У репозиторії з’явився новий файл:

``` Code
parsed_2026-02-07.csv

```

І новий коміт:

```Code
Add parsed CSV: parsed_2026-02-07.csv

```

Це підтверджує, що git push з Docker працює.

### Підсумок
- EC2 піднято

- Docker встановлено

- Репозиторій клоновано

- Docker‑образ зібрано

- Парсер працює

- CSV генерується

- Git push виконується всередині Docker‑контейнера

- Усі проблеми з Git (safe.directory, SSH, user.email) вирішено





