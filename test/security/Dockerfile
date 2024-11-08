FROM python:3.11-slim

LABEL maintainer="Bisman Singh <bismanmadaan1@gmail.com>"

RUN pip install --no-cache-dir flask==3.0.0

WORKDIR /app

COPY <<'SCRIPT' app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return "OK"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
SCRIPT

EXPOSE 5000

CMD ["python", "app.py"]
