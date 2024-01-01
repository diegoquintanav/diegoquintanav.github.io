Title: Python and Docker
Date: 2024-01-01 15:00:00 +0400
Category: Development
Tags: dbt, docker, data-engineering
Slug: pinochet-rettig-v2
Authors: Diego Quintana
Status: published
Summary: Revisiting the Pinochet-Rettig dataset with dbt and docker

## What

This is a follow up to the [Pinochet-Rettig](https://diegoquintanav.github.io/pinochet-neo4j.html) post. I've learned a lot since then and I wanted to revisit the dataset with a more robust approach. I was motivated also by the conmemoration of the [50th anniversary of the coup d'etat in Chile](https://50.cl/).

The project highlights and contributions as of now are:

- [dbt documentation](https://diegoquintanav.github.io/pinochet-analyze-50/dbt_docs)
- [Elementary Report](https://diegoquintanav.github.io/pinochet-analyze-50/elementary) using [Elementary](https://www.elementary-data.com/)
- [FastAPI Docs](https://pinochet-api.fly.dev/docs) hosted on [fly.io](https://fly.io)
- [Graphql endpoint](https://pinochet-api.fly.dev/graphql) using [strawberry-graphql](https://strawberry.rocks/)

I'm using dbt to transform the data and expose it as a REST API using FastAPI with a GraphQL layer, as well as a semantic layer for running SPARQL queries. I'm also serving the api using fly.io, which is a really cool service that is not charging me anything for this project (bills below USD 5 monthly are 100% free as of now).

The data is stored in a Postgres database with postgis, and everything is running in Docker containers.

Make sure to visit the [Github repo](https://github.com/diegoquintanav/pinochet-analyze-50) and its README for more details.

I wish I had more time to work on this, but I'm happy with the results so far. Let me know if you want to contribute!
