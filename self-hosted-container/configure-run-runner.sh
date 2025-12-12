#!/bin/bash

cd /home/fedora/actions-runner

source ./runner.env
source ~/private/github-personal-access-token.env

export PATH=/usr/local/bin:/usr/bin:/home/fedora/.local/bin
echo "Path: ${PATH}"

export REPO_TOKEN=$(./runner-tools -t ${PAT} -o ${REPO_OWNER} -r ${REPO_NAME} get-token)

echo "Configuring Runner and registering with the repo..."

export CONFIG_ARGS="--url ${REPO_URL} --token ${REPO_TOKEN} --name ${RUNNER_NAME} --labels ${RUNNER_LABELS} --unattended"
response=$(./config.sh ${CONFIG_ARGS} --replace || true)
echo "Response:"
printenv response

if [[ $? -ne 0 ]]; then
    echo "Removing Runner ${RUNNER_NAME}..."
    ./config.sh ${CONFIG_ARGS} remove

    echo "Configuring Runner ${RUNNER_NAME}..."
    ./config.sh ${CONFIG_ARGS}
fi

echo "Starting the Runner: ${RUNNER_NAME}..."
./run.sh


