ROOT ?= $(shell pwd)
TODAY ?= $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
COMMIT ?= $(shell git rev-parse HEAD)
SEMVER_VERSION ?= 2.0.0
VERSION ?= $(shell cat .version)

build:
	docker build \
        --no-cache \
        --build-arg BUILD_VERSION=${VERSION} \
        --build-arg BUILD_DATE=${TODAY} \
        --build-arg SCHEMA_NAME=versionbumper \
        --build-arg SCHEMA_VENDOR=mdelapenya \
        --build-arg BUILD_VCS_REF=${COMMIT} \
        --build-arg BUILD_VCS_URL="https://github.com/mdelapenya/versionbumper" \
        -t mdelapenya/versionbumper:${VERSION} \
        .

push:
	echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin
	docker push mdelapenya/versionbumper:${VERSION}
	docker push mdelapenya/versionbumper:latest

update-lib:
	curl https://raw.githubusercontent.com/fsaintjacques/semver-tool/${SEMVER_VERSION}/src/semver \
		--output lib/semver
	chmod +x lib/semver

.PHONY: build push update-lib
