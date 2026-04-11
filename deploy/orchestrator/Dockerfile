FROM python:3.11-slim-bookworm

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir --upgrade pip

COPY orchestrator/pyproject.toml orchestrator/README.md ./
COPY orchestrator/src ./src

RUN pip install --no-cache-dir .

EXPOSE 8080

CMD ["aximate-orchestrator", "serve", "--host", "0.0.0.0", "--port", "8080"]
