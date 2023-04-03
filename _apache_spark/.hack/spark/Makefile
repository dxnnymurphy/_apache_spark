all: build

_DOCKER_IMAGE_NAMESPACE ?= localhost/data-apache-spark
_DOCKER_IMAGE_NAME      ?= spark
_DOCKER_IMAGE_TAG       ?= 3.3.1

.PHONY: build
build: build-docker-fast

.PHONY: build-docker
build-docker:
	echo "Building docker image - $(_DOCKER_IMAGE_NAMESPACE)/$(_DOCKER_IMAGE_NAME):$(_DOCKER_IMAGE_TAG)"
	docker build \
				--build-arg http_proxy=$$http_proxy \
				--build-arg https_proxy=$$https_proxy \
				--no-cache \
				-f .hack/build/docker/Dockerfile \
				-t $(_DOCKER_IMAGE_NAMESPACE)/$(_DOCKER_IMAGE_NAME):$(_DOCKER_IMAGE_TAG) \
				.

.PHONY: build-docker-fast
build-docker-fast:
	echo "Building docker image - $(_DOCKER_IMAGE_NAMESPACE)/$(_DOCKER_IMAGE_NAME):$(_DOCKER_IMAGE_TAG)"
	docker build \
				--build-arg http_proxy=$$http_proxy \
				--build-arg https_proxy=$$https_proxy \
				-f .hack/build/docker/Dockerfile \
				-t $(_DOCKER_IMAGE_NAMESPACE)/$(_DOCKER_IMAGE_NAME):$(_DOCKER_IMAGE_TAG) \
				.
