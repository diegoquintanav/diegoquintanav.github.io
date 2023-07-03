# ---------------------------------------------------------------------------- #
#                      example usage for docker and poetry                     #
# ---------------------------------------------------------------------------- #

# References:
# - https://inboard.bws.bio/docker#docker-and-poetry
# - https://github.com/br3ndonland/inboard/blob/0.45.0/Dockerfile
# - https://github.com/python-poetry/poetry/issues/1178
# - https://github.com/python-poetry/poetry/issues/1178#issuecomment-1238475183
#
# For more on users and groups:
# - https://www.debian.org/doc/debian-policy/ch-opersys.html#uid-and-gid-classes
# - https://stackoverflow.com/a/55757473/5819113
# - https://stackoverflow.com/questions/56844746/how-to-set-uid-and-gid-in-docker-compose
# - https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user
# - https://nickjanetakis.com/blog/running-docker-containers-as-a-non-root-user-with-a-custom-uid-and-gid

# About renewing Arguments at multiple stages:
# - https://stackoverflow.com/a/53682110

# ---------------------------------------------------------------------------- #
#                            global build arguments                            #
# ---------------------------------------------------------------------------- #

# Global ARG, available to all stages (if renewed)
ARG WORKDIR="/blog"

# global username
ARG USERNAME=blogger
ARG USER_UID=1000
ARG USER_GID=1000

# tag used in all images
ARG PYTHON_VERSION=3.9.16

# ---------------------------------------------------------------------------- #
#                                  build stage                                 #
# ---------------------------------------------------------------------------- #

FROM python:${PYTHON_VERSION}-slim AS blog-deps

# Renew args
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID

# Poetry version
ARG POETRY_VERSION=1.4.0

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

RUN groupadd --gid $USER_GID "$USERNAME" \
	&& useradd --uid $USER_UID --gid $USER_GID -m "$USERNAME"

# Add USERNAME to sudoers. Omit if you don't need to install software after connecting.
RUN apt-get update \
	&& apt-get install -y sudo git iputils-ping make \
	&& echo "$USERNAME" ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME

# -------------------------- add python dependencies ------------------------- #

# Install Pipx using pip
RUN python -m pip install --no-cache-dir --upgrade pip pipx==${PIPX_VERSION}
RUN pipx ensurepath && pipx --version

# Install Poetry using pipx
RUN pipx install --force poetry==${POETRY_VERSION}

# work at /blog
WORKDIR ${WORKDIR}
RUN chown -R $USER_UID:$USER_GID ${WORKDIR}

# ---------------------------------------------------------------------------- #
#                                  blog-editor                                 #
# ---------------------------------------------------------------------------- #

FROM blog-deps AS blog-editor

# refresh global arguments
ARG WORKDIR
ARG USERNAME
ARG USER_UID
ARG USER_GID

# continue as non-root user and escalate explictly
USER ${USERNAME}
WORKDIR ${WORKDIR}

# Copy only the files needed for installing dependencies
COPY pyproject.toml poetry.lock ./

# Install dependencies
RUN poetry install --no-root --only main

EXPOSE 8000

# ---------------------------------------------------------------------------- #
#                                  blog build                                  #
# ---------------------------------------------------------------------------- #

FROM blog-editor AS blog-builder

# copy everything needed for building the page
# make sure to run git submodule update --init --recursive before building
COPY --chown=$USER_UID:$USER_GID . .

# refresh global arguments
RUN make publish


# ---------------------------------------------------------------------------- #
#                                  blog serve                                  #
# ---------------------------------------------------------------------------- #

FROM nginx:1.21.3-alpine AS blog-serve

EXPOSE 80

COPY --from=blog-builder /blog/output /usr/share/nginx/html
