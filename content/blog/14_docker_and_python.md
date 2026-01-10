Title: Python and Docker
Date: 2023-09-02 15:00:00 +0200
Category: Development
Tags: python, containers
Slug: python-docker
Authors: Diego Quintana
Status: published
Summary: Getting python containers right

[TOC]

# Update

I have formatted this entry into a workshop format for [Som Energia](https://somenergia.coop), the cooperative I work with at Girona. You can find it [here](https://som-energia.github.io/somenergia-poetry-docker-workshop/).

## What

I've toyed with docker a fair amount of time. There's a lot going on to get a working container so let me summarize a bit of what I'll show here:

1. We use a multistage docker build to separate the **build** (`builder`) stage from the **final** (`app`) stage and a development stage (`dev`) for development purposes.
2. We use `pipx` to install `poetry` and `poetry` to install our dependencies.
3. We pivot from the `app-pre` stage for doing development e.g. using *devcontainers*, and from the `app` stage for production.
4. We create a user and a group to avoid running as root at both levels. At both dev and prod levels, this user may or not may have access to `sudo`.

What follows are my dry, unpolished notes about how to do this. My goal is to turn this into a workshop at some point.

## Docker image requirements

When building a docker image, we wish to achieve the following:

1. Security: we don't want to run as root in production. In development, we may or may not want to run as root. We achieve this by defining a user and a group and granting sudo access depending on the docker build stage. There are rootless options such as *podman* or even docker itself, but I haven't explored them yet.
2. Size: we want to keep the image size as small as possible. We achieve this by using a multistage build where the final image is based on a slim python image and it only contains the virtual environment with the dependencies, installed using `poetry` at a previous stage.
3. Speed: we want to keep the build time as small as possible. We can achieve this by leveraging docker caching and by separating the build stage from the final stage.
4. Flexibility: we want to be able to use the same image for development and production. We achieve this by defining a `dev` stage that is based on the `app-pre` stage and that allows us to install additional dependencies for development purposes.
5. Stability: we want to pin versions for stable builds. We achieve this by defining the versions of `poetry` and `pipx` that we want to use. We use a pyproject.toml file to define the versions of our dependencies.

I'm not going into docker tagging and versioning here, which is much more involved and I haven't figured out yet how to do it elegantly.

## Example project

We'll use a simple python project with a `pyproject.toml` file and a `poetry.lock` file. We'll use `poetry` to install our dependencies.

```bash
mkdir -p myproject
cd myproject
touch pyproject.toml poetry.lock
```

Edit the `pyproject.toml` file to add some dependencies:

```toml
[tool.poetry]
authors = ["Your Name <your@email.ifyouwant>"]
description = "An example project to showcase docker and poetry"
name = "myproject"
version = "0.1.0"

[tool.poetry.dependencies]
python = ">=3.8,<3.11"
cowsay = "^4.0.0"

[build-system]
build-backend = "poetry.core.masonry.api"
requires = ["poetry-core"]
```

## Global variables

We start by defining a global group of variables that will be used across many stages.

```Dockerfile
# ---------------------------------------------------------------------------- #
#                            global build arguments                            #
# ---------------------------------------------------------------------------- #

# Global ARG, available to all stages (if renewed)
ARG WORKDIR="/app"

# global username
ARG USERNAME=bluesmonk
ARG USER_UID=1000
ARG USER_GID=1000

# tag used in all images
ARG PYTHON_VERSION=3.8.9
```

We can reference these variables later at every stage by simply using the same `ARG` statement. For example, we can use `ARG WORKDIR` at every stage to reference the same value.

## The `builder` stage

Give it a read first and then we'll go through it step by step.

```Dockerfile

# ---------------------------------------------------------------------------- #
#                                  build stage                                 #
# ---------------------------------------------------------------------------- #

FROM python:${PYTHON_VERSION}-slim AS builder

# Renew args
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID

# Poetry version
ARG POETRY_VERSION=1.5.1

# Pipx version
ARG PIPX_VERSION=1.2.0

# prepare the $PATH
ENV PATH=/opt/pipx/bin:${WORKDIR}/.venv/bin:$PATH \
 PIPX_BIN_DIR=/opt/pipx/bin \
 PIPX_HOME=/opt/pipx/home \
 PIPX_VERSION=$PIPX_VERSION \
 POETRY_VERSION=$POETRY_VERSION \
 PYTHONPATH=${WORKDIR} \
 # Don't buffer `stdout`
 PYTHONUNBUFFERED=1 \
 # Don't create `.pyc` files:
 PYTHONDONTWRITEBYTECODE=1 \
 # make poetry create a .venv folder in the project
 POETRY_VIRTUALENVS_IN_PROJECT=true

# ------------------------------ add user ----------------------------- #

RUN groupadd --gid $USER_GID "${USERNAME}" \
 && useradd --uid $USER_UID --gid $USER_GID -m "${USERNAME}"

# -------------------------- add python dependencies ------------------------- #

# Install Pipx using pip
RUN python -m pip install --no-cache-dir --upgrade pip pipx==${PIPX_VERSION}
RUN pipx ensurepath && pipx --version

# Install Poetry using pipx
RUN pipx install --force poetry==${POETRY_VERSION}

# ---------------------------- add code specifics ---------------------------- #

# Copy everything to the container
# we filter out what we don't need using .dockerignore
WORKDIR ${WORKDIR}

# make sure the user owns /app
RUN chown -R ${USER_UID}:${USER_GID} ${WORKDIR}

# Copy only the files needed for installing dependencies
COPY --chown=${USER_UID}:${USER_GID} pyproject.toml poetry.lock ${WORKDIR}/

USER ${USERNAME}
```

1. We start by defining the `builder` stage. We use a slim python image as a base image. We use the `AS` keyword to name the stage.
2. We renew the global variables that we defined earlier. We do this because we want to use the same variables at every stage. We can do this by simply using the same `ARG` statement.
3. We define some additional variables that we'll use later. We define the versions of `poetry` and `pipx` that we want to use. We do this because we want to pin versions for stable builds.
4. We define the `$PATH` variable to control and configure python, poetry and pipx installations beforehand
   1. We configure `pipx` installation so that installer uses custom directories.
   2. We also add the virtual environment directory to the path so that we can run the project from anywhere.
   3. We define the `PYTHONPATH` variable to point to the project directory at `/app` so that we can import modules from the project.
   4. We configure poetry using the `POETRY_VIRTUALENVS_IN_PROJECT` variable to make `poetry` create a `.venv` folder in the project, at `/app/.venv`.
5. We add a user and a group to avoid running as root. We don't use this user now, but we will later.
6. We install `pipx` using `pip` and later we install `poetry` using `pipx`.
7. We define our working directory at `/app`. This directory needs to be writable by the user that we created earlier. We also copy the `pyproject.toml` and `poetry.lock` files to the container.
8. We seal the stage by switching to the user that we created earlier. From this point on, all commands will be run as this user unless we switch to another user.

## The `app-pre` stage

This stage starts from the `builder` stage and it installs only main dependencies using `poetry`. We pass the `--no-root` flag to `poetry` to avoid installing the project itself. We use this stage to install dependencies and to create a virtual environment at `/app/.venv`.

```Dockerfile

# ---------------------------------------------------------------------------- #
#                                 app-pre stage                                #
# ---------------------------------------------------------------------------- #

FROM builder AS app-pre

# Install dependencies and creates a a virtualenv at /app/.venv
RUN poetry install --no-root --only main
```

## The `app` stage

This is mostly the same as the builder stage, but with a few changes:

1. We use a slim python image as a base image. We use the `AS` keyword to name the stage. At this point you can use any image you want, provided it has python installed. We make the image tag depend on the python version that we defined earlier.
2. We copy the directory at `/app/.venv` from the `app-pre` stage to the `app` stage. We do this because we want to keep the virtual environment that we created at the `app-pre` stage, but we don't need poetry and pipx anymore.
3. We don't need to install `poetry` and `pipx` anymore, so we remove them from the `$PATH` variable.

```Dockerfile

# ---------------------------------------------------------------------------- #
#                                   app stage                                  #
# ---------------------------------------------------------------------------- #

# We don't want to use alpine because porting from debian is challenging
# https://stackoverflow.com/a/67695490/5819113
FROM python:${PYTHON_VERSION}-slim AS app

# refresh global arguments
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID

# refresh PATH
ENV PATH=/opt/pipx/bin:${WORKDIR}/.venv/bin:$PATH \
 POETRY_VERSION=$POETRY_VERSION \
 PYTHONPATH=${WORKDIR} \
 # Don't buffer `stdout`
 PYTHONUNBUFFERED=1 \
 # Don't create `.pyc` files:
 PYTHONDONTWRITEBYTECODE=1

# ------------------------------ user management ----------------------------- #

RUN groupadd --gid $USER_GID "${USERNAME}" \
 && useradd --uid $USER_UID --gid $USER_GID -m "${USERNAME}"

# ------------------------------- app specific ------------------------------- #

WORKDIR ${WORKDIR}

RUN chown -R ${USER_UID}:${USER_GID} ${WORKDIR}

COPY --from=app-pre --chown=${USER_UID}:${USER_GID} ${WORKDIR} ${WORKDIR}

USER ${USERNAME}

ENTRYPOINT [ "python" ]
CMD [ "--version" ]
```

## The `dev` stage

This stage starts from the `app-pre` stage and it installs all remaining dependencies using `poetry`. It looks like the `app` stage, but with a few changes:

1. We install development dependencies such as `git`, `sudo`, `wget` and `iputils-ping`. We do this because we may want to be able to install additional software after connecting to the container.
2. We install extra python dependencies for development purposes. We do this by adding a `dev` section to the `pyproject.toml` file and by passing the `--no-root` flag to `poetry` to avoid installing the project itself.
3. We add the user to the `sudoers` file. This is not recommended for production.
4. We seal the stage by switching to the user that we created earlier. This user has `sudo` access.

```Dockerfile

# ---------------------------------------------------------------------------- #
#                                   dev stage                                  #
# ---------------------------------------------------------------------------- #

FROM app-pre AS dev

# refresh global arguments
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID


USER root

# Add USERNAME to sudoers. Omit if you don't need to install software after connecting.
RUN apt-get update \
 && apt-get install -y sudo git iputils-ping wget \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

# install all remaning dependencies
RUN poetry install --no-root --with dev

USER ${USERNAME}
```

## Buiding using docker compose

Edit a docker compose file to build the image at `docker-compose.yml`

```yaml
---
name: docker-poetry-project

version: "3.7"
services:
  builder:
    image: "myproject-builder:latest"
    deploy:
      replicas: 0 # never start service, since it is only for build purposes
    build:
      context: .
      dockerfile: Dockerfile
      target: builder
      cache_from:
        - "myproject-builder:latest"
  app:
    image: "myproject-app:latest"
    deploy:
      replicas: 0 # never start service, since it is only for build purposes
    build:
      context: .
      dockerfile: Dockerfile
      target: app
      cache_from:
        - "myproject-builder:latest"
        - "myproject-app:latest"
  app-dev:
    image: "myproject-app-dev:latest"
    build:
      context: .
      dockerfile: Dockerfile
      target: dev
      cache_from:
        - "myproject-builder:latest"
        - "myproject-app-dev:latest"
    volumes:
      - python_venv_app_dev:/app/.venv # mount virtualenv at /venv. See https://stackoverflow.com/a/74015989/5819113
    command: /bin/sh -c "sleep infinity" # keep container running

volumes:
  python_venv_app_dev:
```

A few notes about this file:

1. Using the `cache_from` option, we can use the cache from previous builds. This is useful to speed up the build process.
2. Setting `replicas: 0` ensures that the service is never started. We only use it for building the image.
3. We mount the virtual environment at `/app/.venv` using a *named volume*. This is very important because we don't want to share this directory with the host machine. This is useful for development purposes because otherwise you may run into permission issues when trying to install dependencies from the host machine (e.g. if you decide to use another user id or another group). See <https://stackoverflow.com/a/74015989/5819113> for details.

Using this file, we can build the images using `docker compose build`.

## Try out your new containers

Use docker compose to get a shell inside the `app-dev` container.

```bash
docker compose build
```

```bash
docker compose up -d app-dev
```

```bash
docker compose exec -it --entrypoint bash app-dev
```

```bash
python --version
python -c "import cowsay; cowsay.cow('Hello world')"
ls -la
exit
```

To get inside the `app` container, use `docker compose run --rm -it --entrypoint bash app`.

## Full Dockerfile

```Dockerfile
# ---------------------------------------------------------------------------- #
#                      example usage for docker and poetry                     #
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
#                            global build arguments                            #
# ---------------------------------------------------------------------------- #

# Global ARG, available to all stages (if renewed)
ARG WORKDIR="/app"

# global username
ARG USERNAME=bluesmonk
ARG USER_UID=1000
ARG USER_GID=1000

# tag used in all images
ARG PYTHON_VERSION=3.8.9

# ---------------------------------------------------------------------------- #
#                                  build stage                                 #
# ---------------------------------------------------------------------------- #

FROM python:${PYTHON_VERSION}-slim AS builder

# Renew args
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID

# Poetry version
ARG POETRY_VERSION=1.5.1

# Pipx version
ARG PIPX_VERSION=1.2.0

# prepare the $PATH
ENV PATH=/opt/pipx/bin:${WORKDIR}/.venv/bin:$PATH \
 PIPX_BIN_DIR=/opt/pipx/bin \
 PIPX_HOME=/opt/pipx/home \
 PIPX_VERSION=$PIPX_VERSION \
 POETRY_VERSION=$POETRY_VERSION \
 PYTHONPATH=${WORKDIR} \
 # Don't buffer `stdout`
 PYTHONUNBUFFERED=1 \
 # Don't create `.pyc` files:
 PYTHONDONTWRITEBYTECODE=1 \
 # make poetry create a .venv folder in the project
 POETRY_VIRTUALENVS_IN_PROJECT=true

# ------------------------------ add user ----------------------------- #

RUN groupadd --gid $USER_GID "${USERNAME}" \
 && useradd --uid $USER_UID --gid $USER_GID -m "${USERNAME}"

# -------------------------- add python dependencies ------------------------- #

# Install Pipx using pip
RUN python -m pip install --no-cache-dir --upgrade pip pipx==${PIPX_VERSION}
RUN pipx ensurepath && pipx --version

# Install Poetry using pipx
RUN pipx install --force poetry==${POETRY_VERSION}

# ---------------------------- add code specifics ---------------------------- #

# Copy everything to the container
# we filter out what we don't need using .dockerignore
WORKDIR ${WORKDIR}

# make sure the user owns /app
RUN chown -R ${USER_UID}:${USER_GID} ${WORKDIR}

# Copy only the files needed for installing dependencies
COPY --chown=${USER_UID}:${USER_GID} pyproject.toml poetry.lock ${WORKDIR}/

USER ${USERNAME}


# ---------------------------------------------------------------------------- #
#                                 app-pre stage                                #
# ---------------------------------------------------------------------------- #

FROM builder AS app-pre

# Install dependencies and creates a a virtualenv at /app/.venv
RUN poetry install --no-root --only main

# ---------------------------------------------------------------------------- #
#                                   app stage                                  #
# ---------------------------------------------------------------------------- #

# We don't want to use alpine because porting from debian is challenging
# https://stackoverflow.com/a/67695490/5819113
FROM python:${PYTHON_VERSION}-slim AS app

# refresh global arguments
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID

# refresh PATH
ENV PATH=/opt/pipx/bin:${WORKDIR}/.venv/bin:$PATH \
 POETRY_VERSION=$POETRY_VERSION \
 PYTHONPATH=${WORKDIR} \
 # Don't buffer `stdout`
 PYTHONUNBUFFERED=1 \
 # Don't create `.pyc` files:
 PYTHONDONTWRITEBYTECODE=1

# ------------------------------ user management ----------------------------- #

RUN groupadd --gid $USER_GID "${USERNAME}" \
 && useradd --uid $USER_UID --gid $USER_GID -m "${USERNAME}"

# ------------------------------- app specific ------------------------------- #

WORKDIR ${WORKDIR}

RUN chown -R ${USER_UID}:${USER_GID} ${WORKDIR}

COPY --from=app-pre --chown=${USER_UID}:${USER_GID} ${WORKDIR} ${WORKDIR}

USER ${USERNAME}

ENTRYPOINT [ "python" ]
CMD [ "--version" ]


# ---------------------------------------------------------------------------- #
#                                   dev stage                                  #
# ---------------------------------------------------------------------------- #

FROM app-pre AS dev

# refresh global arguments
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID


USER root

# Add USERNAME to sudoers. Omit if you don't need to install software after connecting.
RUN apt-get update \
 && apt-get install -y sudo git iputils-ping wget \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

# install all remaning dependencies
RUN poetry install --no-root

USER ${USERNAME}
```

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

### About renewing arguments at multiple stages

- <https://stackoverflow.com/a/53682110>
