# NOTE : this makefile is intended for Rob's use, but of course
#   anybody can use it if they know what they're doing.  They
#   will need to modify it, because they won't be able to
#   write to Rob's directory on dockerhub.

VER=test20251110a

docker-images:
	DB_DOCKER_VERSION=${VER} docker compose build
	docker tag ghcr.io/roman-supernova-pit/snpit-db-postgres:${VER} registry.nersc.gov/m4385/rknop/snpit-db-postgres:${VER}
	docker tag ghcr.io/roman-supernova-pit/snpit-db-webserver-test:${VER} registry.nersc.gov/m4385/rknop/snpit-db-webserver-test:${VER}
	docker tag ghcr.io/roman-supernova-pit/snpit-db-postgres:${VER} rknop/snpit-db-postgres:${VER}
	docker tag ghcr.io/roman-supernova-pit/snpit-db-webserver-test:${VER} rknop/snpit-db-webserver-test:${VER}


push-docker-images:
	docker push ghcr.io/roman-supernova-pit/snpit-db-postgres:${VER}
	docker push ghcr.io/roman-supernova-pit/snpit-db-webserver-test:${VER}
	docker push registry.nersc.gov/m4385/rknop/snpit-db-postgres:${VER}
	docker push registry.nersc.gov/m4385/rknop/snpit-db-webserver-test:${VER}
	docker push rknop/snpit-db-postgres:${VER}
	docker push rknop/snpit-db-webserver-test:${VER}

