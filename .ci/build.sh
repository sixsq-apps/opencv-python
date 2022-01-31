#!/bin/bash -xe

tag_name=$(echo ${GITHUB_REF} | awk -F'/' '{print $(NF)}' | sed -e 's/[^a-z0-9\._-]/-/g')
platform=${PLATFORM:-amd64}
DOCKER_ORG=${DOCKER_ORG:-nuvladev}
DOCKER_IMAGE=$(basename `git rev-parse --show-toplevel`)

manifest=${DOCKER_ORG}/${DOCKER_IMAGE}:${tag_name}
dockerfile="Dockerfile"; [[ "$platform" == "arm"* ]] && dockerfile="${dockerfile}.arm"

# Login to docker hub
unset HISTFILE
echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

# Build docker image
docker run --rm --privileged -v ${PWD}:/tmp/work --entrypoint buildctl-daemonless.sh moby/buildkit:master \
       build \
       --frontend dockerfile.v0 \
       --opt platform=linux/${platform} \
       --opt filename=./${dockerfile} \
       --opt build-arg:GIT_BRANCH=${GIT_BRANCH} \
       --opt build-arg:GIT_BUILD_TIME=${GIT_BUILD_TIME} \
       --opt build-arg:GIT_COMMIT_ID=${GITHUB_SHA} \
       --opt build-arg:GITHUB_RUN_NUMBER=${GITHUB_RUN_NUMBER} \
       --opt build-arg:GITHUB_RUN_ID=${GITHUB_RUN_ID} \
       --output type=docker,name=${manifest}-${platform},dest=/tmp/work/target/${DOCKER_IMAGE}-${platform}.docker.tar \
       --local context=/tmp/work \
       --local dockerfile=/tmp/work \
       --progress plain

# Load docker image locally
docker load --input ./target/${DOCKER_IMAGE}-${platform}.docker.tar

# Push platform specific image to docker hub
docker push ${manifest}-${platform}
