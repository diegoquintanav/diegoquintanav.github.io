Title: Pyenv, Poetry and Pipx: three python tools to rule them all
Date: 2023-07-03 01:00:00 +0200
Category: Development
Tags: tools, python, containers
Slug: poetry-primer
Authors: Diego Quintana
Status: published
Summary: Taking back control of your python development tools.

[TOC]

# Update

I have formatted this entry into a workshop format for [Som Energia](https://somenergia.coop), the cooperative I work with at Girona. You can find it [here](https://som-energia.github.io/somenergia-poetry-docker-workshop/).

# Sharpen your axe

> If I had to chop down a tree in eight hours, I would spend six hours sharpening my axe.

This saying is usually attributed to Abraham Lincoln, who [seemed very good at chopping down trees](https://www.thoughtco.com/abe-lincoln-and-his-ax-reality-behind-the-legend-1773585). The idea is that taking care of your tools will make your craft easier. This is true for any craft and specially of software development.

I wrote this as a short tutorial for a job I had. The idea was to introduce [`Poetry`](https://python-poetry.org/) and dependency management to the people I worked with, and to move away from the `requirements.txt` file. These are the tools I use nowadays to manage my python projects and they have been working great for me. I will use Docker to show you how it all fits together, so you don't need to install anything.

# Pin those dependencies

Pinned dependencies are important, as they help maintain and control functionalities of your project. Listing pinned dependencies ensures projects get outdated (i.e. they “rot”) in a _manageable_ and _understandable_ way.

There are some levels to how reproducible your project is:

1. Mention _somewhere evident_ what version of Python your project is supposed to work with. A badge would suffice. See for example [static badges](https://shields.io/badges/static-badge), like this one ![badge](https://img.shields.io/badge/python-3.10-blue).
2. Provide _at least_ a `requirements.txt` with pinned dependencies.
3. Provide a `setup.py` file declaring dependencies.
4. Provide a `pyproject.toml` file in the best case
5. Use a dependency manager such as [`poetry`](https://python-poetry.org/), [`pipenv`](https://pipenv.pypa.io/en/latest/#install-pipenv-today) or [`hatch`](https://hatch.pypa.io/latest/) or [conda](https://docs.conda.io/en/latest/).
6. Bundle everything in a Docker image.
7. Use multistage docker images to build your project.
8. Use a CI/CD tool to automate the process of building and deploying your project.

# Get control of your python environments

Old is the [xkcd comic about python environments](https://xkcd.com/1987/). The gist is that isolated environments are important and you should use them. Even better if you know what python version you are using at all times and where is it installed. `whereis python` is your friend.

Same as with dependencies, there are some levels to how isolated your python environments are:
  
- First level `python -m venv .venv` at your project level
- Second level is to have `pipx` manage your system level utilities, i.e. normally CLI tools like `cowsay` or `poetry` or `black`
- Second level is to let `poetry` manage your virtual environments
- Third level is to let `pyenv` manage your python versions _and_ your environments and let poetry just do dependency management
- Fourth level is some python version manager that does not use shims and does not suck but I don't know of any as of today.
- Fifth level is using Docker to build an isolated environment.

# But first, what is a dependency?

- A project may depend on another library: consider for example the [`pandas`](https://github.com/pandas-dev/pandas) library. You normally install this with `pip install pandas`. That means that your project now has a dependency on `pandas`.
- Pandas is a very large project and it has its own dependencies too. Depending on the complexity of the project, these may be hard to understand at first. For `pandas`, this may be very well listed as [anaconda dependencies](https://github.com/pandas-dev/pandas/blob/main/environment.yml).
- Each library at some point grows past the point where it needs to start tracking such growth through some kind of a versioning system. This is so that users (e.g. other developers like _you_) can write code depending on a specific expectated behaviours.
- Sometimes a change of the version won't mean anything to your own code. Other times, however, it may introduce a change of its expected behaviour when running the same thing. This is loosely referred to as a breaking change. Consider the example for [`distutils` telling its users how to migrate to new versions so their code won't break](https://numpy.org/devdocs/reference/distutils_status_migration.html).

## What is a virtual environment?

Make sure to read this <https://realpython.com/python-virtual-environments-a-primer/> for more info. It's very complete and I won't try to improve on that.

## Why do we need a virtual environment?

- Virtual environment are there to keep you sane.
- A virtual environment is a directory (a.k.a _folder)_ holding a _copy_ of python, isolated from other copies that you may have installed in your system.
  - Oftentimes such an environment is installed in a folder, generally called `.venv`
  - Any libraries installed with `./.venv/bin/python -m pip` are _linked_ to that version, i.e. they will be located under `./.venv/lib/pythonX.Y/site-packages/`
- Imagine the following weird example: You own three python projects, each one with its own dependencies
  - Library A has dependency X with version 1.0.0. Running something like `python -m X.foo` will yield the integer `42`
  - Library B has dependency Y with version 2.0.0.
  - Library C has dependency X with version 3.0.0. Running something like `python -m X.foo` will yield `None`
- You have now a dependency conflict: A and C have the same dependency, but with different versions
  - Library A does not support version 3.0.0 of dependency X, and vice versa
  - Can’t go installing and uninstalling versions every time I want to use A or C. I expect a `42` on the first case and a `None` on the second.
- Solution: install two instances of python at different locations that can coexist because their dependencies are now isolated: we have a _separated_ version of python installed per each project

## The easy win: using `virtualenv`

`virtualenv` is the standard library. That means that without installing any other dependency, `python -m venv .venv` will create a copy of python within a folder called `.venv`. This folder will contain something like this:

```bash
.venv/
├── bin
├── include
├── lib
└── lib64 -> lib
```

And you normally "activate" it by calling the script inside `/bin/activate`. 

## The "a bit more involved" win using `pyenv` + `pipx` + `poetry`

In short, it means

- Let [pyenv](https://github.com/pyenv/pyenv) manage versions of python. Follow their instructions to install it.
  - Create a virtual environment with `pyenv virtualenv 3.9.10 <environment-name>`.
  - Activate it with `pyenv activate <environment-name>`.
  - Let pyenv automatically activate an environment after entering a folder with `pyenv local <environment-name>`.
  - If you are running Windows, you can use [pyenv-win](https://github.com/pyenv-win/pyenv-win)
- let [pipx](https://github.com/pypa/pipx) manage your system level utilities e.g. `poetry`
- let [poetry](https://github.com/python-poetry/poetry) manage dependencies
  - install it system-wide with `pipx install poetry`
  - poetry creates virtual environments by default, _we want to deactivate it_
    - `poetry config virtualenvs.create false`
    - `poetry config virtualenvs.in-project false`

# A demonstration using Docker

> Spoiler: you will need docker. You can get free containers using [play-with-docker](https://labs.play-with-docker.com/).

Start by launching a new container named `my-python-environment` with the latest version of ubuntu and run a bash shell. The `--rm` flag will remove the container after you exit it so it won't clutter your system.

```bash
docker run -it --name my-python-environment --rm ubuntu:latest bash`
```

You are now starting from a clean slate. Let's install some dependencies.

```bash
apt update && apt install curl git vim build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -y
curl https://pyenv.run | bash
```

You will now have `pyenv` installed. Let's configure it. As per the instructions, we need to add the following to our `~/.bashrc` file:

```bash
vim ~/.bashrc
```

Go to the end of the file and add the following:

```bash
# Load pyenv automatically by appending
# the following to
#~/.bash_profile if it exists, otherwise ~/.profile (for login shells)
# and ~/.bashrc (for interactive shells) :

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

Save and quit. Now we need to refresh our shell to load the new configuration:

```bash
exec "$SHELL"
```

You can now use `pyenv` to install a new version of python. Let's install version `3.10.9`:

```bash
pyenv install 3.10.9
```

Let's make it available globally:

```bash
pyenv global 3.10.9
```

We can also install different versions of python and switch between them:

```bash
pyenv install 3.8.12
```

We have now python 3.10.9 installed globally. Let's install `pipx` with it:

```bash
python3 -m pip install --upgrade pip
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

Again, we need to refresh our shell to load the new configurations:

```bash
exec "$SHELL"
```

Let's install `poetry` with `pipx`:

```bash
$ pipx install poetry==1.4.2 --force
```

And confirm it's installed with:

```bash
$ poetry --version
Poetry (version 1.4.2)
$ whereis poetry
poetry: /root/.local/bin/poetry
```

We want to configure poetry to not create virtual environments by default:

```bash
# configure poetry
poetry config virtualenvs.create false`
poetry config virtualenvs.in-project false`
```

We can create a new project with poetry named `mypackage`:

```bash
# create project
mkdir ~/mypackage
cd ~/mypackage
```

We will now create a virtual environment for this project only

```bash
pyenv virtualenv 3.10.9 myenv
pyenv activate myenv
pyenv rehash # refresh pyenv shims
```

use poetry dialog to create new project

```bash
poetry init
```

The dialog will ask you a few questions. You can skip them by pressing enter. The dialog will then create a `pyproject.toml` file. You can now manage dependencies with poetry:

```bash
poetry add pandas
```

and remove dependencies

```bash
poetry remove pandas
```

Every time you `add` or `remove` packages with poetry, two things happen:

- the `pyproject.toml` file is updated and a new line is added or deleted under the dependencies section
- a `poetry.lock` file is created or updated, containing the exact versions of the dependencies you are using and their relations.

Let's install `cowsay` with `poetry`:

```bash
poetry add cowsay
poetry add --group dev black
pyenv rehash # to update shims
cowsay hola # a cow should greet you, in spanish
  ____
| hola |
  ====
    \
     \
       ^__^
       (oo)\_______
       (__)\       )\/\
           ||----w |
           ||     ||

```

# Writing your project as a CLI with `poetry`

```bash
cd ~/mypackage
mkdir mypackage
touch mypackage/__init__.py
touch mypackage/cli.py
```

Open `mypackage/cli.py` and add the following:

```bash
import cowsay

def cli():
    return cowsay.cow('Hello World')

if __name__ == "__main__":
    cli()
```

Confirm that your program works by running it with `python mypackage/cli.py`:


```bash
$ python mypackage/cli.py
___________
| Hello World |
  ===========
           \
            \
              ^__^
              (oo)\_______
              (__)\       )\/\
                  ||----w |
                  ||     ||
```

We can update our `pyproject.toml` file to include a CLI entrypoint:

```bash
[tool.poetry]
name = "mypackage"
version = "0.1.0"
description = "some description"
authors = ["Your Name <youremail@yopmail.com>"]
readme = "README.md"
packages = [{include = "mypackage"}] # new

[tool.poetry.dependencies]
python = "^3.10"
pandas = "^2.0.0"
cowsay = "^5.0"

[tool.poetry.scripts]
mypackage-cli = "mypackage.cli:cli" # new

[tool.poetry.group.dev.dependencies]
black = "^23.3.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

And now we can install our package with `poetry` and run our little CLI by calling `mypackage-cli`:

```bash
poetry install  # install package along with its CLI
pyenv rehash # refresh python shims
mypackage-cli # launch cli
```

# Building and publishing your project

Make sure you have a valid account at [pypi](https://pypi.org/). You can create one [here](https://pypi.org/account/register/).


Run `poetry build` (at the level where a valid `pyproject.toml` is present). From this point on, you have two options:
  
## Publish to pypi

Run  `poetry publish --username myprivaterepo --password <password> --repository pypi`

## Publish to a private repository

if you wish to publish to a private repository, say, `pypi.myprivaterepo.org`:

- Add repository to the `config` in poetry, with `poetry config repositories.myprivaterepo https://pypi.myprivaterepo.org/`
- Careful to not add the `/simple` bit if your privare repo is using [`pypiserver`](https://hub.docker.com/r/pypiserver/pypiserver), see <https://github.com/pypiserver/pypiserver/issues/329#issuecomment-688883871>
- now your private pypi \*\*\*\*repository is aliased with `myprivaterepo`

Now you can run  `poetry publish --username myprivaterepo --password <password> --repository myprivaterepo`. See <https://python-poetry.org/docs/libraries#publishing-to-pypi> for more documentation


## Creating your own private repository using docker compose

Launch your own pypi repository with <https://github.com/pypiserver/pypiserver> and <https://github.com/pypiserver/pypiserver/blob/master/docker-compose.yml>


## Adding dependencies from private repositories to pyproject.toml

You may also want to add dependencies from private repositories. These repos normally need keys to access them. Make sure to follow the instructions from your private repository to add credentials to your `pyproject.toml` file. Generally, the process is as follows:


1. Add a `source` to `pyproject.toml` file

   1. `poetry source add myprivaterepo https://pypi.myprivaterepo.org`
   2. This should modify your `pyproject.toml` file and will add something like this

      ```toml
      [[tool.poetry.source]]
      name = "myprivaterepo"
      url = "https://pypi.myprivaterepo.org/"
      default = false
      secondary = false
      ```

2. Add credentials for that repository
   1. `poetry config http-basic.myprivaterepo <user> <password>`
3. Add dependencies using the `--source` argument

   ```bash
   poetry add --source myprivaterepo my-private-package=0.2.1
   ```

# Managing virtual environments inside docker

Last but not least. People tend to argue over such scenario. _Is isolation within isolation necessary? Is a virtual environment needed inside a docker container?_ See

- <https://github.com/python-poetry/poetry/discussions/1879#discussioncomment-346113>
- <https://github.com/python-poetry/poetry/pull/3209#issuecomment-710678083>

Answer is “_it depends_”, but it gives more control over dependencies and their state. I prefer it using docker multistage builds. I will cover this in a next post hopefully soon.

Until next time!
