#!/usr/bin/env bash

set -euxo pipefail

docker run --rm -v "${PWD}:/mnt" -w /mnt ghcr.io/xu-cheng/texlive-full bash -euxc "apk add poppler-utils && make jpg pdf png svg mostlyclean"
