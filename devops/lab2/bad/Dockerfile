# Плохая практика 1: Использование latest тега
FROM python:latest

# Плохая практика 2: Запуск от root пользователя (по умолчанию)
# Не создаём отдельного пользователя

# Плохая практика 3: Установка всех пакетов в одном слое без кеширования
WORKDIR /app
COPY ../app/ /app/
RUN pip install flask redis gunicorn requests numpy pandas scikit-learn

# Плохая практика 4: Копирование всех файлов без фильтрации
COPY . .

# Плохая практика 5: Хардкод переменных окружения
ENV DATABASE_PASSWORD=admin123
ENV API_KEY=secret_key_12345

# Плохая практика 6: Использование shell формы CMD
CMD python main.py