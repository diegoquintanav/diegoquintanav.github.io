#!/bin/bash
docker-compose -f /path/to/docker/compose/file exec -T db pg_dump -U postgres postgres --no-owner | gzip -9 > /opt/db-backups/demo-backup-$(date +%d-%m-%y).sql.gz