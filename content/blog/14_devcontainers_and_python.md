Title: Python, Docker and devcontainers
Date: 2023-07-03 02:00:00 +0200
Category: Development
Tags: python, containers
Slug: python-devcontainers
Authors: Diego Quintana
Status: draft
Summary: Getting devcontainers right with python and multistage docker builds

## Example multistage docker image


I've toyed with this fair amount of time. There's a lot going on so let me wrap it up for you:

1. We use a multistage docker build to separate the build stage from the app stage
2. We use `pipx` to install `poetry` and `poetry` to install our dependencies
3. We install dependencies at a app-pre stage and copy them to the app stage
4. We pivot from the `app-pre` stage for launching devcontainers and from the `app` stage for production
5. We create a user and a group to avoid running as root at both levels. At both dev and prod levels, this user may or not may have access to sudo.



```docker
## ---------------------------------------------------------------------------- #
##                      example usage for docker and poetry                     #
## ---------------------------------------------------------------------------- #

## ---------------------------------------------------------------------------- #
##                                  build stage                                 #
## ---------------------------------------------------------------------------- #

## Global ARG, available to all stages (if renewed)
ARG WORKDIR="/app"

## tag used in all images
ARG PYTHON_VERSION=3.9.16

FROM python:${PYTHON_VERSION} AS builder

## Renew (https://stackoverflow.com/a/53682110):
ARG WORKDIR

## Poetry version
ARG POETRY_VERSION=1.4.0

## Pipx version
ARG PIPX_VERSION=1.2.0

## prepare the $PATH
ENV PATH=/opt/pipx/bin:${WORKDIR}/.venv/bin:$PATH \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PIPX_HOME=/opt/pipx/home \
    PIPX_VERSION=$PIPX_VERSION \
    POETRY_VERSION=$POETRY_VERSION \
    PYTHONPATH=${WORKDIR} \
    ## Don't buffer `stdout`
    PYTHONUNBUFFERED=1 \
    ## Don't create `.pyc` files:
    PYTHONDONTWRITEBYTECODE=1 \
    ## make poetry create a .venv folder in the project
    POETRY_VIRTUALENVS_IN_PROJECT=true

## Install Pipx using pip
RUN python -m pip install --no-cache-dir --upgrade pip pipx==${PIPX_VERSION}
RUN pipx ensurepath && pipx --version

## Install Poetry using pipx
RUN pipx install --force poetry==${POETRY_VERSION}

## Copy everything to the container, we filter out what we don't need using .dockerignore
WORKDIR ${WORKDIR}
COPY pyproject.toml poetry.lock ./

## ---------------------------------------------------------------------------- #
##                                   app pre-stage                              #
## ---------------------------------------------------------------------------- #

FROM builder as app-pre

## Install dependencies
RUN poetry install --with dev

## ---------------------------------------------------------------------------- #
##                                   app stage                                  #
## ---------------------------------------------------------------------------- #

## We don't want to use alpine
## https://stackoverflow.com/a/67695490/5819113
FROM python:${PYTHON_VERSION}-slim as app

## refresh ARG
ARG WORKDIR

## refresh PATH
ENV PATH=/opt/pipx/bin:${WORKDIR}/.venv/bin:$PATH \
    POETRY_VERSION=$POETRY_VERSION \
    PYTHONPATH=${WORKDIR} \
    ## Don't buffer `stdout`
    PYTHONUNBUFFERED=1 \
    ## Don't create `.pyc` files:
    PYTHONDONTWRITEBYTECODE=1

WORKDIR ${WORKDIR}

COPY --from=app-pre ${WORKDIR} .

## ---------------------------------------------------------------------------- #
##                                user management                               #
## ---------------------------------------------------------------------------- #

## For more on users and groups
## see https://www.debian.org/doc/debian-policy/ch-opersys.html#uid-and-gid-classes
## see https://stackoverflow.com/a/55757473/5819113
## see https://stackoverflow.com/questions/56844746/how-to-set-uid-and-gid-in-docker-compose
## see https://nickjanetakis.com/blog/running-docker-containers-as-a-non-root-user-with-a-custom-uid-and-gid

ARG UID
ARG GID
ARG UNAME

ENV UID=${UID:-1000}
ENV GID=${GID:-1000}
ENV UNAME=${UNAME:-somenergia}

RUN groupadd \
    --gid $GID \
    "$UNAME" && \
    useradd \
    --no-log-init \
    --home-dir "${WORKDIR}" \
    --uid $UID \
    --gid $GID \
    --no-create-home \
    "$UNAME"

USER ${UID}

## ---------------------------------------------------------------------------- #
##                             App-specific settings                            #
## ---------------------------------------------------------------------------- #

ENTRYPOINT [ "python" ]
CMD [ "--version" ]
```

## Docker compose file


```yaml
---
version: "3"
services:
  app:
    image: "${DOCKER_IMAGE?Variable not set}:${DOCKER_TAG-latest}"
    build:
      context: .
      dockerfile: Dockerfile
      target: app
      args:
        - "UID=${UID:-1000}"
        - "GID=${GID:-1000}"
        - "UNAME=${UNAME:-myname}"

  builder:
    image: "${DOCKER_IMAGE?Variable not set}:${DOCKER_TAG-latest}-builder"
    build:
      context: .
      dockerfile: Dockerfile
      target: builder
      args:
        - "UID=${UID:-1000}"
        - "GID=${GID:-1000}"
        - "UNAME=${UNAME:-somenergia}"
```

```yaml
docker compose build
```

## Devcontainer

<!-- todo -->

## References

### About docker and poetry

- <https://inboard.bws.bio/docker#docker-and-poetry>
- <https://github.com/br3ndonland/inboard/blob/0.45.0/Dockerfile>
- <https://github.com/python-poetry/poetry/issues/1178>
- <https://github.com/python-poetry/poetry/issues/1178#issuecomment-1238475183>

### For more on users and groups

- <https://www.debian.org/doc/debian-policy/ch-opersys.html#uid-and-gid-classes>
- <https://stackoverflow.com/a/55757473/5819113>
- <https://stackoverflow.com/questions/56844746/how-to-set-uid-and-gid-in-docker-compose>
- <https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user>
- <https://nickjanetakis.com/blog/running-docker-containers-as-a-non-root-user-with-a-custom-uid-and-gid>

### About renewing Arguments at multiple stages

- <https://stackoverflow.com/a/53682110>
