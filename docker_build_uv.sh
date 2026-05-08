#!/usr/bin/env bash

set -x

docker pull ghcr.io/prefix-dev/pixi:noble

docker system prune -f

docker build \
    --file ./uv_Dockerfile \
    --tag scikit-build-core-debug:uv \
    .
