# Version Manager

This Docker image pretends to define an opinionated way to manage the versioning process of a software project which already follows **semantic versioning**.

It uses the awesome [`semver` script](https://github.com/fsaintjacques/semver-tool) created by @fsaintjacques, wrapping it in a Docker container and adding an entrypoint to perform specific tasks related to versioning.

The process will consist in the following steps:

- Read the versioning file in your project
- Calculate the next version related to the bump you are doing: minor, major, patch, etc.
- Stash your existing changes in the git branch you are working on
- Move to the master branch
- Create a git commit in the master branch with the bump
- Create a git tag at that commit with the bump, removing existing with same same
- Move to your working branch
- Pop stashd changes

## Supported Project types

At this moment we support NodeJS, Gradle and custom type projects.

### NodeJS

We read the `package.json` file at project root folder, and we execute `npm version $TYPE` to perform the bump.

### Gradle

We read the `gradle.properties` file at project root folder, and look for the `version=` key. Then we replace that value to perform the bump.

### Custom type

We read a `VERSION.txt` file at the project root folder, which must contain just a valid Semver version. Then we replace that value to perform the bump.

This `VERSION.txt` file acn be overriden passing a `VERSION_FILENAME` environment variable, with the name of the file containing the Semver version value.


## Volumes

It's mandatory to define a volume to your project's workspace, so that the running container is able to find the versioning descriptor.

## Environment variables

Following environment variables **must** be set in the running container:

### ALLOW_GIT_TAG

Defines whether the running container creates a Git tag on your project or not.

If not set, the running container create the git tag. If you want to disallow the creation of the tag, set this environment variable with any value different than `true`.

### DRY_RUN

Defines whether the running container performs the operations or it simply logs a message.

If not set, the running container will perform the operations. If you want to show the results of the execution, set this environment variable with a value of `true`.

### PROJECT_NAME

Defines the name of the project to be versioned.

### VERSION_FILENAME

Defines the name of the file containing a semantic versioning, valid version value.

If not set, the running container will try to read a file named `VERSION.txt` in the root folder of your project's workspace.

### VERSION_TYPE

Defines the type of the increment to be performed. The valid values are:

| Type | Description |
|:---- |:----------- |
|major|Updates the `X` part of a `x.y.z` version, which is a positive integer|
|minor|Updates the `Y` part of a `x.y.z` version, which is a positive integer|
|patch|Updates the `X` part of a `x.y.z` version, which is a positive integer|
|prerel `prerel`|Optional string composed of alphanumeric characters and hyphens|
|build `build`|Optional string composed of alphanumeric characters and hyphens.|

If we read [the docs](https://github.com/fsaintjacques/semver-tool/blob/master/README.md#usage) from `semver` tool:

**version**: A version must match the following regex pattern:
```
SEMVER_REGEX="^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"
```
In english, the version must match X.Y.Z(-PRERELEASE)(+BUILD) where X, Y and Z are positive integers, `PRERELEASE` is an optional string composed of alphanumeric characters and hyphens and `BUILD` is also an optional string composed of alphanumeric characters and hyphens.

## Examples

Creating a minor change in Dry-Run mode:
```shell
$ docker run --rm \
    -v $PATH_TO_YOUR_PROJECT:/version \
    -e DRY_RUN=true \
    -e PROJECT_NAME=mdelapenya/myimage \
    -e VERSION_TYPE=minor \
    mdelapenya/versionbumper:1.0.0
```

Creating a minor change in a Docker image:
```shell
$ docker run --rm \
    -v $PATH_TO_YOUR_PROJECT:/version \
    -e PROJECT_NAME=mdelapenya/myimage \
    -e VERSION_TYPE=minor \
    mdelapenya/versionbumper:1.0.0
```

Creating a patch change in a project:
```shell
$ docker run --rm \
    -v $PATH_TO_YOUR_PROJECT:/version \
    -e PROJECT_NAME=myapp \
    -e VERSION_TYPE=patch \
    mdelapenya/versionbumper:1.0.0
```

Creating a patch change in a project using a different version file:
```shell
$ docker run --rm \
    -v $PATH_TO_YOUR_PROJECT:/version \
    -e VERSION_FILENAME=.version 
    -e PROJECT_NAME=myapp \
    -e VERSION_TYPE=patch \
    mdelapenya/versionbumper:1.0.0
```