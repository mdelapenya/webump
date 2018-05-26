#!/bin/bash

readonly PROJECT_NAME="${PROJECT_NAME}"
readonly ALLOW_GIT_TAG="${ALLOW_GIT_TAG:-true}"
readonly VERSION_FILENAME="${VERSION_FILENAME:-VERSION.txt}"
readonly VERSION_TYPE="${VERSION_TYPE}"
readonly WORKDIR="/version"
readonly VERSION_FILE="${WORKDIR}/${VERSION_FILENAME}"
readonly GIT_CONFIG_USER_NAME="versionbumper"
readonly GIT_CONFIG_USER_EMAIL="versionbumper@versionbumper.io"

function relaunch() {
    echo "Please set it up and relaunch."
}

function validate() {
    validateEnvVar "PROJECT_NAME"
    validateEnvVar "VERSION_TYPE"

    if [ ! -f $VERSION_FILE ]; then
        echo -n -e " \033[1;31m
    The version file [${VERSION_FILE}] does not exist.
    $(relaunch)
    \033[0m"
        exit 1
    fi
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

function increaseVersion() {
    local version=$(cat ${VERSION_FILE})
    local versionType=${VERSION_TYPE}

    readonly newVersion=$(semver bump $versionType $version)

    echo -n -e " \033[1;32m
    Performing a $versionType increment on $version version, which results in:
    $PROJECT_NAME:$newVersion
    "

    cd $WORKDIR

    local currentBranchName=$(git rev-parse --abbrev-ref HEAD)

    echo "Setting git config for ${GIT_CONFIG_USER_NAME} and ${GIT_CONFIG_USER_EMAIL}"

    git config --global user.name "${GIT_CONFIG_USER_NAME}"
    git config --global user.email "${GIT_CONFIG_USER_EMAIL}"

    git stash
    git checkout master

    echo $newVersion > ${VERSION_FILE}

    git add ${VERSION_FILE}
    git commit -m "Bump $versionType version: $newVersion"

    if [ "${ALLOW_GIT_TAG}" == "true" ]; then
        local gitTag="v$newVersion"

        echo -n -e "
    Creating Git tag for $newVersion: ${gitTag}
    "
        git tag -d ${gitTag} 2>/dev/null || true
        git tag ${gitTag}
    fi

    git checkout $currentBranchName
    git stash pop || true
}

function main {
    increaseVersion
}

validate

main "$@"