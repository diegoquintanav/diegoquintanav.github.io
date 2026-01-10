# Repo onboarding notes for code agents

Purpose: Help an autonomous coding agent understand this Pelican-based static blog repository, run and modify it safely, and follow established conventions.

Summary
- This repository is a personal blog built with Pelican. Content lives in `content/`, generated HTML is placed in `output/`. The site uses the `pelican-alchemy` theme and supports Markdown and Jupyter notebooks (`.ipynb`). The canonical site URL is set in `publishconf.py` to `https://diegoquintanav.github.io`.

Tech stack
- Python 3.8+ (pyproject specifies ^3.8.1)
- Static site generator: Pelican (pyproject: `pelican ^4.8.0`)
- Markdown, Jupyter support via `pelican-jupyter` and `pelican-render-math`
- Packaging & virtualenv: Poetry (`pyproject.toml`)
- Development tooling: `black`, `flake8`, `isort`, `ruff`, `pre-commit`
- Container: Docker (Dockerfile + docker-compose.*.yml present)

How to run (local dev)
- Recommended: use Poetry to create a reproducible environment:

```bash
poetry install      # installs virtualenv in .venv (POETRY_VIRTUALENVS_IN_PROJECT=true)
poetry run make html
poetry run make devserver PORT=8000
```

- Direct `make` (requires `pelican` available on PATH or via Poetry):

```bash
make html                 # generate into output/
make serve PORT=8000      # serve once
make devserver PORT=8000  # serve + autoreload
```

- Docker (isolated build/runtime):

```bash
make docker.html     # build inside container and generate output
make docker.serve    # run container with service ports
make docker.publish  # run publish inside docker
```

Useful Makefile vars
- `DEBUG=1` — enable Pelican debug output
- `RELATIVE=1` — build with relative URLs
- `PORT` — port used by serve/devserver
- `SERVER` — binding for `serve-global`

Other ways to run
- `invoke` tasks are defined in `tasks.py` (eg. `invoke build`, `invoke serve`, `invoke publish`). These call Pelican similarly to Makefile.

Project structure (high level)
- `content/` — Markdown and notebook source (posts, pages)
- `themes/`, `themes/pelican-alchemy/` — theme code and overrides
- `output/` — generated site (ignored in source control or deployed)
- `plugins/` & `pelican_plugins/` — custom/local Pelican plugins
- `pyproject.toml` — dependencies and tool config (Poetry)
- `Makefile` — common build/serve/publish targets
- `Dockerfile`, `docker-compose*.yml` — containerized build/serve
- `pelicanconf.py`, `publishconf.py` — dev vs production Pelican configs
- `tasks.py` — `invoke` tasks for common operations

Coding guidelines
- Follow the existing repository style: simple, small, and clear changes.
- Python code: run `black` and `isort`, and `ruff`/`flake8` as desired before committing. A `pre-commit` config is present in `pyproject.toml` dev deps.
- Keep content (Markdown) and code (plugins/theme) changes separate in commits.
- Avoid committing `output/` (it's generated). Don't commit local `.venv` or long caches.

Common pitfalls & notes
- The project expects a Poetry-managed environment. If Pelican is not on PATH, use `poetry run ...`.
- The Dockerfile references building a `blog-builder` stage and notes `git submodule update --init --recursive` — ensure any theme submodules are initialized before building images.
- Local `.venv` and `.venv/` contents may exist in this workspace; exclude these folders during repo-wide searches to avoid noise.
- Some dependencies (Jupyter, nb templates) require additional files (see `themes/nb_templates/` and `pelican_jupyter` settings in `pelicanconf.py`).

What to do first when you see this repo
1. Read `README.md` and `Makefile` to learn common targets.
2. Run `poetry install` (or `poetry update` if lockfile needs refresh) to create `.venv`.
3. Run `make html` to confirm a build succeeds. If it fails, check Python version and Pelican errors, and prefer `poetry run make html`.
4. For containerized work, use `make docker.html` to reproduce the environment.

Where to look for help
- Pelican docs: https://docs.getpelican.com/
- Theme docs: `themes/pelican-alchemy` repo and its README
- Poetry docs for dependency management

Developer contact
- Repo owner: Diego Quintana (see author in `pyproject.toml`)

Short checklist for automated edits
- Don't modify `output/` directly — change sources in `content/`.
- Run the build locally (`make html`) and verify `output/` contains expected HTML.
- Run linters/formatters before committing.

If you use this file to implement a change, update it with any new pitfalls or improved run steps discovered during the work.

Troubleshooting
- If `make html` fails with "pelican: No such file or directory", you are likely missing the virtual environment tools on PATH. Run:

```bash
poetry install
poetry run make html
```

- If you prefer not to use Poetry, install Pelican globally (not recommended):

```bash
python3 -m pip install --user pelican
make html
```

Updating git submodules

This repo contains several git submodules (themes and plugins). Keep them initialized and up-to-date before building or when the theme/plugin code changes. Common commands:

```bash
# initialize submodules (first clone)
git submodule update --init --recursive

# update all submodules to the commit recorded in the superproject
git submodule update --recursive

# fetch latest remote commits for each submodule and merge into checked-out branch
git submodule update --remote --merge --recursive

# if submodule URLs or paths changed in .gitmodules
git submodule sync --recursive
git submodule update --init --recursive

# inspect configured submodules
cat .gitmodules
git submodule status --recursive
```

Notes:
- You can initialize/update a single submodule (for example the theme) with:

```bash
git submodule update --init --recursive themes/pelican-alchemy
```

- The Docker-based build in `Dockerfile` expects submodules to be present; run `git submodule update --init --recursive` before building or let your CI checkout include submodules (for example `actions/checkout@v4` with `submodules: recursive`).


