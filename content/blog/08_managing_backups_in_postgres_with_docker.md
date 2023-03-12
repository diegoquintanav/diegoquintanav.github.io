Title: Dumping postgres databases with Docker
Date: 2019-03-14 21:10:00 +0100
Category: Web Development
Tags: docker, postgres
Slug: dumping-postgres-db-with-docker
Authors: Diego Quintana
Status: published
Summary: How to manage postgres backups with docker

*It's been a while* since I posted something. I started living in another country, and time has become scarce. This is a short post from my *developer journal*.

`Docker` and `postgres` work really good together. If you don't believe me, check their image [documentation](https://hub.docker.com/_/postgres).

Take for instance, the barebones example given there:

```yml
# Use postgres/example user/password credentials
version: '3.1'

services:

  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: example

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
```

With this file, you can get a living postgres instance in seconds with something like `docker-compose up -d`.

## Managing database backups with `pg_dump`

The simplest way to backup a `postgres` database is using [`pg_dump`](https://www.postgresql.org/docs/10/app-pgdump.html). From the host, you can issue this using

```bash
docker-compose exec db pg_dump -U postgres postgres --no-owner | gzip -9  > db-backup-$(date +%d-%m-%y).sql.gz
```

This executes `pg_dump` inside the running container specified in the `docker-compose.yml`
file as the service `db`, and stores the result in the host as a `gzip` compressed file.

Here, passing `--no-owner` ensures that the database backup will be importable into any other database, regardless of user privileges. **Use this with care**.

Importing this backup into another database living in another container can be done in two ways:

- copying the file or mounting it in the container and importing it, from *inside the container*
- Pipe the file from the host to the container through `stdin`

I personally like the second approach better, as it doesn't require modifying any files inside the container:

```bash
gunzip -c path/to/db-backup.sql.gz | docker-compose exec -T db psql -U postgres postgres
```

Note that we need to pass `-T` to disable `TTY` allocation. Also, we could use `docker` instead of `docker-compose`, with something like  `docker exec -i $(docker-compose ps -q db)`.

These tasks can scheduled to be run at specific times with [cron](https://crontab.guru/). More info on backups [here](https://www.postgresql.org/docs/10/backup-dump.html#BACKUP-DUMP-RESTORE).
