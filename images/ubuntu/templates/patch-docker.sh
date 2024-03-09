# Ask founders@ for credentials.
#!/bin/bash

set -e

DOCKER_TAG="110324-1"
DOCKER_USERNAME=""
DOCKER_ACCESS_TOKEN=""
DOCKER_REPOSITORY=""
DOCKER_IMAGE=$(docker build -q -f Dockerfile .)

docker tag "$DOCKER_IMAGE" "$DOCKER_REPOSITORY:$DOCKER_TAG"

echo "$DOCKER_ACCESS_TOKEN" | docker login --username "$DOCKER_USERNAME" --password-stdin

docker push "$DOCKER_REPOSITORY:$DOCKER_TAG"

