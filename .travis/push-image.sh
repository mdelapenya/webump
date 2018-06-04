#!/bin/bash

set -o errexit

readonly IMAGE_PREFIX=${IMAGE_PREFIX:-mdelapenya}
readonly IMAGE_TAG=${IMAGE_TAG:-staging}

main() {
  docker_login
  push_image
}

docker_login() {
  echo ${DOCKER_PASSWORD} | docker login --username ${DOCKER_USERNAME} --password-stdin
}

push_image() {
  local image=$1
  local name=${IMAGE_PREFIX}/versionbumper
  local full_name=${name}:${IMAGE_TAG}

  echo -n -e " \033[1;31m
  Will push image $full_name
  \033[0m"

  docker push ${full_name}
  docker tag ${full_name} ${name}:latest
	docker push ${name}:latest
}

main "$@"
