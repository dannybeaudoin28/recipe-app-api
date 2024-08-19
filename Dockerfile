FROM python:3.9-alpine3.13
LABEL maintainer="dannybeaudoin16"

ENV PYTHONUNBUFFERED 1

# Copy requirements and application files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

COPY fullchain.pem /etc/ssl/certs/fullchain.pem
COPY privkey.pem /etc/ssl/certs/privkey.pem

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./app /app

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8000

# Set ARG for development
ARG DEV=false

# Install dependencies and setup Python environment
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

ENV PATH="/py/bin:$PATH"

USER django-user

ENTRYPOINT ["/entrypoint.sh"]

# Default command to run your application (replace with your actual command)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]