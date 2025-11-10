# Хорошая практика 1: Использование конкретной версии
FROM python:3.11-slim-bookworm AS builder

# Установка зависимостей в отдельном слое для кеширования
WORKDIR /tmp
COPY app/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Финальный образ
FROM python:3.11-slim-bookworm

# Хорошая практика 2: Создание непривилегированного пользователя
RUN useradd -m -u 1000 appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

WORKDIR /app

# Копирование зависимостей из builder стадии
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Хорошая практика 3: Копирование только необходимых файлов
COPY --chown=appuser:appuser app/main.py .

# Переключение на непривилегированного пользователя
USER appuser

# Добавление .local/bin в PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Хорошая практика 4: Использование exec формы CMD
CMD ["python", "main.py"]

# Хорошая практика 5: Добавление HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1