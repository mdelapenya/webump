ROOT ?= $(shell pwd)
TODAY ?= $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
COMMIT ?= $(shell git rev-parse HEAD)
SEMVER_VERSION ?= 2.0.0
VERSION ?= $(shell cat .version)

build:
	ROOT=${ROOT} TODAY=${TODAY} COMMIT=${COMMIT} SEMVER_VERSION=${SEMVER_VERSION} VERSION=${VERSION} ./build-images.sh

push:
	echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin
	docker push mdelapenya/versionbumper:${VERSION}
	docker push mdelapenya/versionbumper:latest

update-lib:
	curl https://raw.githubusercontent.com/fsaintjacques/semver-tool/${SEMVER_VERSION}/src/semver \
		--output lib/semver
	chmod +x lib/semver

.PHONY: build push update-lib
