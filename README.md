# About

Hello, World! This is my github site. Feel free to look around. It is developed using [Pelican](https://getpelican.com/), a static site generator written in Python.

## Deploying the blog

You can build, serve and publish the site using the provided `Makefile` targets.

- **Build (generate HTML):**

```bash
make html
```

- **Serve locally (single run):**

```bash
make serve PORT=8000
```

- **Serve and regenerate on changes (development):**

```bash
make devserver PORT=8000
```

- **Create a production build (uses `publishconf.py`):**

```bash
make publish
```

- **Clean generated files:**

```bash
make clean
```

- **Run via Docker (uses `docker-compose.dev.yml`):**

```bash
make docker.html     # generate with docker
make docker.serve    # serve with docker (service ports)
make docker.publish  # publish using docker
```

Notes:

- Generated site files are placed in the `output/` directory.
- Environment variables supported by the `Makefile`:
   	- `DEBUG=1` — enable Pelican debug output
   	- `RELATIVE=1` — enable relative URLs
   	- `PORT` — port used by `serve` and `devserver`
   	- `SERVER` — host binding for `serve-global`
