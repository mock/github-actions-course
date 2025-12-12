# Self-Hosted Container Runners

This is a guide on how to run self hosted runners in containers on a local system. For my explanation, I'm running Linux (Fedora) locally and using Podman for my container management.

## Container Image

The container image is essentially a Dockerfile building out the container with a few few things I might need for building and troubleshooting. The container definition file is `github-runner-fedora`. This will use a Fedora container image as a base. There are two main sections: Setting up the system under the root user and finishing a few setup pieces along with installing the runner software as a fedora user.

The latter part of the file is where the runner software is downloaded and extracted. A few files contribute to the building process: `runner.env`, `build-runner.sh`, `configure-run-runner.sh`, and `runner-tools`.

The `runner.env` file sets up some variables which can be customized for each iteration of an image build. This includes runner release version and repository information. The `build-runner.sh` is what gets the actual runner software and extracts it inside the image when built. `runner-tools` is used for simplifying extraction of certain tokens and runner information using Github API calls. A user's personal access token is used when making these calls to pull the specific information necessary to configure the runner. `configure-run-runner.sh` is the file which handles configuring the runner for the repo and the starting and stopping. It will also handle removing a runner which might be in the way when starting up a new runner.

The user's (owner's) personal access token is provided in a file called `github.personal-access-token.env`. It should in this format:

```bash
export PAT=ghp_s0mel0ngstr1ngOfLetters4ndNumber5
```

This file should *not* be saved within the repo. In fact, it should be saved elsewhere on the file system and then mounted to the `/home/fedora/private` directory on the running container.

## Building the Image

A few customizations need to be made first. These are values defined in the `runner.env` file.

- `REPO_OWNER`: This is the user account (owner) of repository.

- `REPO_NAME`: This should be the name of the repository where the runner will be registered.

- `REPO_URL`: This would be the full URL of the repository's location at github.com with the owner and name substituted.

- `RUNNER_LABELS`: This should be list of the labels to identify the runner when specifying the `runs-on` parameter in the Github workflow.

`RUNNER_VERSION` and`RUNNER_HASH` can be found by visiting the **Settings** > **Runners** page in the repository and pressing the "New self-hosted runner" button.  There will be instructions for configuring a self- hosted runner. These values can be verified and pulled if they ever need to be changed.

`RUNNER_NAME` can be something customized or just the name of the repository. If several runners will be configured, have this value reflect those different runners.

To build the runner container, use Podman with this statement:

```bash
$ podman build -t fedora-github-actions-runner -f github-runner-fedora .
```

This will name the image `fedora-github-actions-runner`. Feel free to choose a different name if something sounds better. This should build an image you can now use as your personal self-hosted runner for your repository.

```bash
$ podman images
REPOSITORY                              TAG         IMAGE ID      CREATED            SIZE
localhost/fedora-github-actions-runner  latest      a351a8761c05  About an hour ago  2.34 GB
registry.fedoraproject.org/fedora       latest      b5be7094e533  11 hours ago       186 MB
```

The `localhost/fedora-github-actions-runner` image is our self-hosted runner image. We are now ready to start the runner:

```bash
$ podman run -t localhost/fedora-github-actions-runner
```

That will create a container for our self-hosted runner image.

```shellsession
podman run -t localhost/fedora-github-actions-runner
Path: /usr/local/bin:/usr/bin:/home/fedora/.local/bin
Configuring Runner and registering with the repo...
Response:
Removing Runner github-actions-course...

--------------------------------------------------------------------------------
|        ____ _ _   _   _       _          _        _   _                      |
|       / ___(_) |_| | | |_   _| |__      / \   ___| |_(_) ___  _ __  ___      |
|      | |  _| | __| |_| | | | | '_ \    / _ \ / __| __| |/ _ \| '_ \/ __|     |
|      | |_| | | |_|  _  | |_| | |_) |  / ___ \ (__| |_| | (_) | | | \__ \     |
|       \____|_|\__|_| |_|\__,_|_.__/  /_/   \_\___|\__|_|\___/|_| |_|___/     |
|                                                                              |
|                       Self-hosted runner registration                        |
|                                                                              |
--------------------------------------------------------------------------------
Cannot configure the runner because it is already configured. To reconfigure the runner, run 'config.cmd remove' or './config.sh remove' first.
Configuring Runner github-actions-course...

--------------------------------------------------------------------------------
|        ____ _ _   _   _       _          _        _   _                      |
|       / ___(_) |_| | | |_   _| |__      / \   ___| |_(_) ___  _ __  ___      |
|      | |  _| | __| |_| | | | | '_ \    / _ \ / __| __| |/ _ \| '_ \/ __|     |
|      | |_| | | |_|  _  | |_| | |_) |  / ___ \ (__| |_| | (_) | | | \__ \     |
|       \____|_|\__|_| |_|\__,_|_.__/  /_/   \_\___|\__|_|\___/|_| |_|___/     |
|                                                                              |
|                       Self-hosted runner registration                        |
|                                                                              |
--------------------------------------------------------------------------------
Cannot configure the runner because it is already configured. To reconfigure the runner, run 'config.cmd remove' or './config.sh remove' first.
Starting the Runner: github-actions-course...

√ Connected to GitHub

Current runner version: '2.329.0'
2025-12-12 17:32:46Z: Listening for Jobs
```

This is showing two attempts made to start the runner. In this case, a runner with a matching name already existed. It will make first remove the older runner reference and replace it with a fresh one. At the end, you can see the status of it to be listening for jobs.

If you refresh the **Settings** > **Runners** page, you can see the new self-hosted runner listed and sitting an idle state ready to run some workflow.


