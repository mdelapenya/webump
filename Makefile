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
        --build-arg SCHEMA_NAME=webump \
        --build-arg SCHEMA_VENDOR=mdelapenya \
        --build-arg BUILD_VCS_REF=${COMMIT} \
        --build-arg BUILD_VCS_URL="https://github.com/mdelapenya/webump" \
        -t mdelapenya/webump:${VERSION} \
        .

push:
	IMAGE_TAG=${VERSION} .travis/push-image.sh

update-lib:
	curl https://raw.githubusercontent.com/fsaintjacques/semver-tool/${SEMVER_VERSION}/src/semver \
		--output lib/semver
	chmod +x lib/semver

.PHONY: build push update-lib
