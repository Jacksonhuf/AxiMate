FROM python:3.11-slim-bookworm

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir --upgrade pip

COPY worker/pyproject.toml worker/README.md ./
COPY worker/src ./src

RUN pip install --no-cache-dir .

EXPOSE 8090

ENV AXIMATE_WORKER_TRANSPORT=http

CMD ["uvicorn", "aximate_worker.http_app:app", "--host", "0.0.0.0", "--port", "8090"]
