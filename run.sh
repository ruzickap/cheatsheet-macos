#!/usr/bin/env bash

# Build LaTeX documents with make inside a TeX Live Docker container

set -euo pipefail

# renovate: datasource=docker depName=ghcr.io/xu-cheng/texlive-full versioning=docker
TEXLIVE_IMAGE="ghcr.io/xu-cheng/texlive-full:20261001@sha256:c06416ebbc69c8e90e07d1f1a6f7a3f9b334e773daa3543ce879ea533317c3a7"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: ${0} [MAKE_TARGETS...]"
  echo "Env: LATEX_DOCKER_IMAGE (default: ${TEXLIVE_IMAGE})"
  echo "     LATEX_MAKE_TARGETS (default: jpg pdf png svg mostlyclean)"
  exit 0
fi

DOCKER_IMAGE="${LATEX_DOCKER_IMAGE:-${TEXLIVE_IMAGE}}"
MAKE_TARGETS="${*:-${LATEX_MAKE_TARGETS:-jpg pdf png svg mostlyclean}}"

# Runs as root so apk can install poppler-utils (pdftoppm for jpg/png);
# the image is amd64-only, so pin the platform for arm64 hosts
docker run --rm --platform linux/amd64 --volume "${PWD}:/mnt" --workdir /mnt "${DOCKER_IMAGE}" \
  sh -euxc "apk add --no-cache poppler-utils && make ${MAKE_TARGETS}"
