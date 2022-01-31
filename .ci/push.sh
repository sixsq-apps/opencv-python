#!/bin/bash -xe

tag_name=$(echo ${GITHUB_REF} | awk -F'/' '{print $(NF)}' | sed -e 's/[^a-z0-9\._-]/-/g')
DOCKER_ORG=${DOCKER_ORG:-nuvladev}
DOCKER_IMAGE=$(basename `git rev-parse --show-toplevel`)

manifest=${DOCKER_ORG}/${DOCKER_IMAGE}:${tag_name}
platforms=(${PLATFORMS:-amd64})
manifest_args=(${manifest})

# Login to docker hub
unset HISTFILE; set +x; echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin; set -x

# Pull images from docker hub
for platform in "${platforms[@]}"; do
    docker image pull ${manifest}-${platform}
    manifest_args+=("${manifest}-${platform}")
done

# Create manifest
docker manifest create "${manifest_args[@]}"

# Annotate manifest
for platform in "${platforms[@]}"; do
    docker manifest annotate ${manifest} ${manifest}-${platform} --arch ${platform}
done

# Push manifest to docker hub
docker manifest push --purge ${manifest}
