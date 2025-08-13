# NOTE : this makefile is intended for Rob's use.
# Anybody should be able to use it, but notice that it builds images
#  with "rknop" in the tag.  If you're using it locally (with "make
#  docker-images"), that's fine, but you probably won't be able to push
#  these images to (at least) dockerhub.

VER=unknown_version

docker-images:
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target snpit_env \
		-t registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER) -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target snpit_dev_env \
		-t registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev-$(VER) -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target snpit_env \
		-t registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-$(VER) -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target snpit_dev_env \
		-t registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev-$(VER) -f docker/Dockerfile .
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER) \
		registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev-$(VER) \
		registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-$(VER) \
		registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev-$(VER) \
		registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER) \
		docker.io/rknop/roman-snpit-env:cpu-$(VER)
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER) \
		docker.io/rknop/roman-snpit-env:cpu
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev-$(VER) \
		docker.io/rknop/roman-snpit-env:cpu-dev-$(VER)
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER) \
		docker.io/rknop/roman-snpit-env:cpu-dev
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-$(VER) \
		docker.io/rknop/roman-snpit-env:cuda-$(VER)
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER) \
		docker.io/rknop/roman-snpit-env:cuda
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev-$(VER) \
		docker.io/rknop/roman-snpit-env:cuda-dev-$(VER)
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev-$(VER) \
		docker.io/rknop/roman-snpit-env:cuda-dev

push-docker-images:
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER)
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev-$(VER)
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-$(VER)
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev-$(VER)
	docker push registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev
	docker push docker.io/rknop/roman-snpit-env:cpu-$(VER)
	docker push docker.io/rknop/roman-snpit-env:cpu
	docker push docker.io/rknop/roman-snpit-env:cpu-dev-$(VER)
	docker push docker.io/rknop/roman-snpit-env:cpu-dev
	docker push docker.io/rknop/roman-snpit-env:cuda-$(VER)
	docker push docker.io/rknop/roman-snpit-env:cuda
	docker push docker.io/rknop/roman-snpit-env:cuda-dev-$(VER)
	docker push docker.io/rknop/roman-snpit-env:cuda-dev
