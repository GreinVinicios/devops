#!/usr/bin/env bash
set -euo pipefail
TAG=${1:-'0.0.1'}

docker build \
--no-cache \
-t greinvinicios/jenkins-agent:$TAG . && \
docker push greinvinicios/jenkins-agent:$TAG