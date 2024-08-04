# FROM python:3.9-alpine3.13
# LABEL maintainer="dannybeaudoin16"

# ENV PYTHONUNBUFFERED 1

# COPY ./requirements.txt /tmp/requirements.txt
# COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# COPY ./app /app
# WORKDIR /app
# EXPOSE 8000

# ARG DEV=false
# RUN python -m venv /py && \
#     /py/bin/pip install --upgrade pip && \
#     apk add --update --no-cache postgresql-client && \
#     apk add --update --no-cache --virtual .tmp-build-deps \
#         build-base postgresql-dev musl-dev && \
#     /py/bin/pip install -r /tmp/requirements.txt && \
#     if [ $DEV = "true" ]; \
#         then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
#     fi && \
#     rm -rf /tmp && \
#     apk del .tmp-build-deps && \
#     adduser \
#         --disabled-password \
#         --no-create-home \
#         django-user

# ENV PATH="/py/bin:$PATH"

# USER django-user

FROM python:3.9-alpine3.13
LABEL maintainer="dannybeaudoin16"

ENV PYTHONUNBUFFERED 1

# Copy requirements and application files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the wait-for-db script
COPY wait_for_db.sh /wait_for_db.sh
RUN chmod +x /wait_for_db.sh

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
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user

# Default command to run your application (replace with your actual command)
CMD ["./wait_for_db.sh", "recipe-container", "python", "manage.py", "runserver", "0.0.0.0:8000"]
