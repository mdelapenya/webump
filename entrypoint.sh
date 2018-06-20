#!/bin/bash

readonly DRY_RUN="${DRY_RUN:-false}"
readonly ALLOW_GIT_TAG="${ALLOW_GIT_TAG:-true}"
readonly VERSION_FILENAME_GRADLE="gradle.properties"
readonly VERSION_FILENAME_NODEJS="package.json"
readonly VERSION_TYPE="${VERSION_TYPE}"
readonly WORKDIR="/version"
readonly GIT_CONFIG_USER_NAME="${GIT_CONFIG_USER_NAME:-webump}"
readonly GIT_CONFIG_USER_EMAIL="${GIT_CONFIG_USER_EMAIL:-webump@webump.io}"

VERSION_FILENAME="${VERSION_FILENAME:-VERSION.txt}"
VERSION_FILE="${WORKDIR}/${VERSION_FILENAME}"
VERSIONING_MODE="custom"

function detectLanguage() {
  if [ -f ${WORKDIR}/${VERSION_FILENAME_NODEJS} ]; then
    VERSIONING_MODE="nodejs"
    VERSION_FILENAME=${VERSION_FILENAME_NODEJS}
  elif [ -f ${WORKDIR}/${VERSION_FILENAME_GRADLE} ]; then
    VERSIONING_MODE="gradle"
    VERSION_FILENAME=${VERSION_FILENAME_GRADLE}
  elif [ -f ${WORKDIR}/${VERSION_FILENAME} ]; then
    VERSIONING_MODE="custom"
    VERSION_FILENAME=${VERSION_FILENAME}
  else
    echo -n -e " \033[1;31m
    The version file [${VERSION_FILE}] does not exist.
    $(relaunch)
    \033[0m"
    exit 1
  fi

  echo -n -e " \033[1;32m
    ${VERSIONING_MODE} project detected.
    \033[0m"

  VERSION_FILE="${WORKDIR}/${VERSION_FILENAME}"
}

function readVersionFromFile() {
  case ${VERSIONING_MODE} in
  gradle)
    while IFS='=' read -r key value; do
      key=$(echo $key | tr '.' '_')

      eval "${key}='${value}'"
    done <"$VERSION_FILE"

    echo "${version}"
    ;;
  nodejs)
    echo "$(cat ${VERSION_FILE} | jq '.version' | sed s/\"//g)"
    ;;
  *)
    echo "$(cat ${VERSION_FILE})"
    ;;
  esac
}

function relaunch() {
  echo "Please set it up and relaunch."
}

# ${1}: oldVersion
# ${2}: newVersion
# ${3}: bump type
function updateVersionFile() {
  case ${VERSIONING_MODE} in
  gradle)
    sed -i "s/version=${1}/version=${2}/g" ${VERSION_FILE}
    ;;
  nodejs)
    npm version ${3}
    ;;
  *)
    echo ${2} >${VERSION_FILE}
    ;;
  esac
}

function validate() {
  validateEnvVar "VERSION_TYPE"
}

function validateEnvVar() {
  local var=${1}

  if [ -z ${!var} ]; then
    echo -n -e " \033[1;31m
    The environment variable ${var} is required to continue.
    $(relaunch)
    \033[0m"
    exit 1
  else
    echo -n -e " \033[1;32m
    ${var} = ${!var}
    \033[0m"
  fi
}

function bumpVersion() {
  local version=$(readVersionFromFile)
  local versionType=${VERSION_TYPE}

  readonly newVersion=$(semver bump ${versionType} ${version})
  readonly gitTag="v${newVersion}"

  if [ "${gitTag}" == "v" ]; then
    echo -n -e " \033[1;31m
    The version present at [${VERSION_FILE}] does not follow Semver: ${version}
    $(relaunch)
    \033[0m"
    exit 1
  fi

  echo -n -e " \033[1;32m
    Performing a ${versionType} increment on ${version} version, which results in: ${newVersion}
    \033[0m"

  cd $WORKDIR

  local currentBranchName=$(git rev-parse --abbrev-ref HEAD)

  if [ "${DRY_RUN}" == "true" ]; then
    echo "The file ${VERSION_FILENAME} will be replaced with ${newVersion}"
    echo "A commit in master branch with this ${versionType} increment will be created in the repository."

    if [ "${ALLOW_GIT_TAG}" == "true" ]; then
      echo "The ${gitTag} git tag will be created in the repository."
    fi
  else
    echo "Setting git config for ${GIT_CONFIG_USER_NAME} and ${GIT_CONFIG_USER_EMAIL}"

    git config --global user.name "${GIT_CONFIG_USER_NAME}"
    git config --global user.email "${GIT_CONFIG_USER_EMAIL}"

    git stash
    git checkout master

    updateVersionFile ${version} ${newVersion} ${versionType}

    git add ${VERSION_FILE}
    git commit -m "Bump ${versionType} version: ${newVersion}"

    if [ "${ALLOW_GIT_TAG}" == "true" ]; then
      echo -n -e "
        Creating Git tag for ${newVersion}: ${gitTag}
        "
      git tag -d ${gitTag} 2>/dev/null || true
      git tag ${gitTag}
    fi

    git checkout ${currentBranchName}
    git stash pop || true
  fi
}

function main() {
  detectLanguage
  validate
  bumpVersion
}

main "$@"
