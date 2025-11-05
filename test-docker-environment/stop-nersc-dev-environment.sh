#!/bin/sh

echo "Stopping shell"
podman-hpc stop shell
podman-hpc rm shell
echo "Stopping webserver"
podman-hpc stop webserver
podman-hpc rm webserver
echo "Cleaning up createdb"
podman-hpc rm createdb
echo "Stopping postgres"
podman-hpc stop postgres
podman-hpc rm postgres
echo "Stopping mailhog"
podman-hpc stop mailhog
podman-hpc rm mailhog
echo "Deleting postgres volume"
podman-hpc volume rm roman-snpit-postgres-data
