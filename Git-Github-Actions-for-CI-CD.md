# Git + Github Actions for CI/CD

**Udemy course:** https://udemy.com/course/git-github-actions-for-ci-cd/

Michal Hucko

Git tutorial: [GitHub - misohu/git-tutorial: Tutorial for git basics](https://github.com/misohu/git-tutorial)

Github Actions course: [GitHub - misohu/github-actions-course: Course for github actions](https://github.com/misohu/github-actions-course)

Practice repo: [GitHub - mock/github-actions-course: Following along with the Udemy tutorial to practice Github Actions](https://github.com/mock/github-actions-course)

Action repos:

- https://github.com/mock/docker-action

- https://github.com/mock/js-action

- https://github.com/mock/python-action

------

DockerHub authentication used the Github login credentials.

----

All workflow for Github Actions is in the `.github` from the root of the repo. Directory: `.github/workflows`. These are the heart of the Actions.

Jobs are units of work within a workflow. They can have steps running on a specific runner. Jobs can be run in sequence or in parallel. They can have dependencies on other jobs.

Steps are individual actions or commands in the jobs. These are executed in order and have dependencies.

Events are activities that trigger a workflow run. See the list of all events: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows.

Actions are reusable units of code performing specific tasks within workflows.

Runners are the servers (instances, containers) which execute workflows when triggered.

### Workflow Files

YAML formatted files.

`name` of the workflow

`on:` for the trigger events for the workflow (multiple allowed)

`jobs:` the jobs for the workflow, each job specified by name

`steps:` are the itemized actions to run 

### Steps

Each step has a name. Optional, but an id is helpful. Shell commands can be provided to have the operations.

Exit codes are returned. `0` indicates success. Non-zero codes are failures. The step will be listed as failed.

#### Conditionals steps

Based on the exit codes, conditions can determine how things are handled.

Expressions follow the `if:` keyword. They are denoted by the `${{ success() }}` or `${{ failure() }}` expressions. Failures will stop subsequent steps from running.

The `${{ failure() }}` will process the step when there is a failure. This can be used for cleaning up on failures.

### Jobs

Multiple jobs can run in parallel.

Each job is defined by name and how it will run (`runs-on`) along with the steps for each job.

### Events

#### Push

This trigger will cause the workflow when code is pushed to any branch of the repo.

```yaml
on: push
```

#### Pull

Triggered on workflow when pull request is opened or updated. Very popular.

```yaml
on:
  pull_request:
```

#### Scheduled

Triggered on a specific time (pattern). The pattern is the POSIX cron syntax.

```yaml
schedule:
  - cron: "23 0 * * 2"
```

#### Issues

Executes a workflow on an issue event in Github. Issues are for discussion, organizing, and prioritizing tasks, bugs, or feature requests in a Github repo.

```yaml
on:
  issues:
    types: [opened, edited, milestoned]
```

#### workflow_call

Used to indicate a workflow which can be called by another workflow.

```yaml
on: workflow_call
```

#### workflow_dispatch

This is for manually triggering. Inputs can be provided in custom variables.

#### workflow_run

This will run when other workflows specified by name reach a certain state (i.e. "completed").

### Actions

Actions are reusable units of code that perform specific tasks within your workflow. These are scripts or executables packaged with metadata, inputs, and outputs. They allow you to modularize and share common functionality across different workflows or repos.

#### Checkout

This action allows you to move code to the job machine in Github.

https://github.com/actions/checkout

#### Passing data between steps

`Input` and `Output` are depreciated.

`GITHUB_OUTPUT` variable to pass data **out** of the step in the workflow. Receiving step, use expression `${{ steps.sender_step_id.outputs.output_name }}` to retrieve the data.

Always `id` the sending step for reference.

#### Passing data between jobs

Jobs run in parallel by default. Making jobs serial using the `needs` parameter. This will be a list of jobs.

#### Artifacts

Way to persist data between jobs in workflow. Files can be shared or data produced by one job with subsequent jobs. These can be used to store build outputs, test results, or any other files to preserve.

For large files, use Github Actions artifacts.

Output: `actions/upload-artifact` to publish files or directories as artifacts

Input: `actions/download-artifact` to retrieve artifacts in another job

#### Secrets and Variables

Sensitive data can be centralized and stored within in the repo. These can be protected based on the Github repo.

Secrets are not exposed in logs.

Variables can be global (to the repo) and environmental (certain grouping). Secrets can be categorized in the same way.

#### Matrix

This feature allows for parallel testing across multiple configurations. It's a key-value pair set of different options. Jobs are run for each combination of the the matrix values.

```yaml
jobs:
  example_matrix:
    strategy:
      matrix:
        os: [ubuntu-22.04, ubuntu-20.04]
        python-version: [3.13, 3.14]
        include:
          - node-version: 20
          - node-version: 19
            java-version: 7
        exclude:
          - os: ubuntu-20.04
            python-version: '3.13'
    runs-on: ${{ matrix.os }}
    steps:
      - name: Install Python
        uses: actions/setup-python@v4
        with:
          python-version: '${{ matrix.python-version }}'
```

#### Reusable workflows

These are templates which can be used across repos. They are defined in a central repository.

#### Permissions

Controlling which actions a workflow can perform within a repo. This is important for security and managing access to sensitive operations.

`GITHUB_TOKEN` is an automatically generated token provided by Github Actions. It allows workflows to interact with the Github API and perform actions on behalf of workflow initiator. Authenticated Github API requests can be made with it without additional setup required.

The permissions on `GITHUB_TOKEN` are dependent on the user or app which triggers the workflow. They are derived from the user, for example. A `permissions:` clause can override the default values.

#### Personal Access Tokens (PATs)

Authentication tokens can perform Github operations and workflows without exposing account password.

Temp token for this course: `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`

#### Contexts

These are environmental and provide access details such as event information and repo and workflow details. They are mostly used in the `if:` statements with this syntax: `${{ context.property }}`.

Some contexts:

- `vars`

- `secrets`

- `job`

- `github`

- `steps`

- `runner`

- `env`

- `matrix`/`strategy`

- `inputs`/`outputs`

#### Expressions

`${{ <expression> }}` is the syntax for expressions.

##### Literals

- Boolean (true, false)

- `null`

- Numbers (2, -123, 10.23, 0xff, -299e-2)

- Strings (this is a string, `${{ 'this is a string' }}`)

##### Operators

- `.` (dot)

- `>`, `<`, `==`

- `!`

- `( )`

- `[ ]`

- `&&`, `||`

### Self-Hosted Runners

Runners are virtual machines responsible for running jobs defined in workflows. These are highly customizable and can execute workflows in various environments.

Github-hosted are run in Github's environment. They are maintained by Github.

Self-hosted can be run on personal infrastructure. They are maintained by the owner of the hosting environment.

### On-Demand Self-Hosted Runners

Self-hosted runners in the cloud can be costly. On-demand can reduce costs.

Smaller free-tier instances are the hosts for spinning up and passing off workflows to larger instances.

### Custom Actions

Ugh. JavaScript. `:P`

These can be common actions to be shared with a team, company, or community.

This will be done using Docker. We'll need a `Dockerfile`, `Entrypoint`, and an `action.yaml` file.

Actions should be kept on the specific task. Use environment variables for configuration. Also good documentation, proper testing, and good release versioning.

The Python example includes composite actions. The are multiple individual actions into a single action.

### Advanced Topics

Debugging code from within it the runner can be done with a tmate action. Tmate will use SSH key via terminal.

Optimizing free space on the runners is accomplished using the **easimon/maximize-build-space** action. Free versions have between 28 GB to 30 GB and pre-installed utilities. 

Running Terraform in the runners.


