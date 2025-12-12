#!/bin/bash

cd /home/fedora/actions-runner

echo "Read Runner values..."
source ./runner.env

echo "Downloading runner image: ${RUNNER_FILENAME}..."
curl -o ${RUNNER_FILENAME} -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILENAME}

echo "Verify file..."
echo "${RUNNER_HASH}  ${RUNNER_FILENAME}" | shasum -a 256 -c

echo "Extract file contents..."
tar -xf ./${RUNNER_FILENAME}

