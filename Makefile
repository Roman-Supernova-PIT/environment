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
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev-$(VER) \
		docker.io/rknop/roman-snpit-env:cpu-dev
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-$(VER) \
		docker.io/rknop/roman-snpit-env:cuda-$(VER)
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-$(VER) \
		docker.io/rknop/roman-snpit-env:cuda
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev-$(VER) \
		docker.io/rknop/roman-snpit-env:cuda-dev-$(VER)
	docker tag registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev-$(VER) \
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

pull-docker-images:
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-$(VER)
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev-$(VER)
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-$(VER)
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev-$(VER)
	docker pull registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev
	docker pull docker.io/rknop/roman-snpit-env:cpu-$(VER)
	docker pull docker.io/rknop/roman-snpit-env:cpu
	docker pull docker.io/rknop/roman-snpit-env:cpu-dev-$(VER)
	docker pull docker.io/rknop/roman-snpit-env:cpu-dev
	docker pull docker.io/rknop/roman-snpit-env:cuda-$(VER)
	docker pull docker.io/rknop/roman-snpit-env:cuda
	docker pull docker.io/rknop/roman-snpit-env:cuda-dev-$(VER)
	docker pull docker.io/rknop/roman-snpit-env:cuda-dev

# This next one creates an image for every build stage, in case you want
#   to diagnose how big each build stage is.  Just run "make mess".
mess:
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target cpu-base \
		-t roman-snpit-env:cpu-base -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target cpu-build-base \
		-t roman-snpit-env:cpu-build-base -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target pip-install-cpu \
		-t roman-snpit-env:pip-install-cpu -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target compilations  \
		-t roman-snpit-env:compilations -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target snpit_env \
		-t roman-snpit-env:spit_env -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target snpit_dev_env \
		-t roman-snpit-env:spit_dev_env -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target cpu-base \
		-t roman-snpit-env:cuda_cpu-base -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target cuda-base \
		-t roman-snpit-env:cuda_cuda-base -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target cuda-build-base \
		-t roman-snpit-env:cuda_cuda-build-base -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target pip-install-cpu \
		-t roman-snpit-env:cuda_pip-install-cpu -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target pip-install-cuda \
		-t roman-snpit-env:cuda_pip-install-cuda -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target compilations \
		-t roman-snpit-env:cuda_compilations -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target snpit_env \
		-t roman-snpit-env:cuda_snpit_env -f docker/Dockerfile .
	DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cuda" --target snpit_dev_env \
		-t roman-snpit-env:cuda_snpit_dev_env -f docker/Dockerfile .
