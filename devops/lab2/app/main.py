from flask import Flask, jsonify
import os
import redis

app = Flask(__name__)

# Получаем конфигурацию из переменных окружения
PORT = int(os.environ.get('PORT', 5000))
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
REDIS_HOST = os.environ.get('REDIS_HOST', 'redis')

@app.route('/')
def hello():
    return jsonify({
        "message": "Hello from Docker!",
        "environment": os.environ.get('ENVIRONMENT', 'unknown'),
        "version": os.environ.get('APP_VERSION', '1.0.0')
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=DEBUG)