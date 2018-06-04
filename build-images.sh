#!/bin/bash

set -o errexit

build_default_flavour() {
    git checkout master

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
}

build_gradle_flavour() {
    git checkout gradle

    docker build \
		--no-cache \
        --build-arg BUILD_VERSION=${VERSION} \
        --build-arg BUILD_DATE=${TODAY} \
        --build-arg SCHEMA_NAME=versionbumper \
        --build-arg SCHEMA_VENDOR=mdelapenya \
        --build-arg BUILD_VCS_REF=${COMMIT} \
        --build-arg BUILD_VCS_URL="https://github.com/mdelapenya/versionbumper/tree/gradle" \
		-t mdelapenya/versionbumper:${VERSION}-gradle \
		.
}

build_nodejs_flavour() {
    git checkout nodejs

    docker build \
		--no-cache \
        --build-arg BUILD_VERSION=${VERSION} \
        --build-arg BUILD_DATE=${TODAY} \
        --build-arg SCHEMA_NAME=versionbumper \
        --build-arg SCHEMA_VENDOR=mdelapenya \
        --build-arg BUILD_VCS_REF=${COMMIT} \
        --build-arg BUILD_VCS_URL="https://github.com/mdelapenya/versionbumper/tree/nodejs" \
		-t mdelapenya/versionbumper:${VERSION}-nodejs \
		.
}

main() {
    build_default_flavour
    build_nodejs_flavour
    build_gradle_flavour
}

main "$@"