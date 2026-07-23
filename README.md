# GitHub Actions Workflow Templates

Reusable GitHub Actions workflow templates with test fixtures. Each workflow targets a minimal sample project under `test/` so you can validate the pipeline end-to-end before adapting it to a real repository.

Maintainer: Bisman Singh <bismanmadaan1@gmail.com>

---

## Workflows

### 1. Docker Build (`docker-build.yml`)

Builds a Docker image from `test/docker/Dockerfile` without pushing. Tags the image with the short commit SHA, branch name, and `latest`.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `IMAGE_NAME` | `test-app` | Name used when tagging the built image |

**Triggers:** push to `main`, pull request to `main`

**Actions used:**
- `actions/checkout@v4`
- `docker/setup-buildx-action@v3`
- `docker/build-push-action@v5`

---

### 2. Helm Lint & Test (`helm-lint-test.yml`)

Runs `helm lint` and `helm template` against the chart in `test/helm/`. Catches syntax errors, missing values, and template rendering issues before anything reaches a cluster.

| Parameter | Default | Description |
|-----------|---------|-------------|
| Helm version | `v3.14.0` | Version installed by setup-helm |

**Triggers:** push or pull request when files in `test/helm/` change

**Actions used:**
- `actions/checkout@v4`
- `azure/setup-helm@v4`

---

### 3. Node.js CI (`node-ci.yml`)

Installs dependencies, lints with ESLint, runs Jest tests, and executes a build step for the Express app in `test/node/`.

| Parameter | Default | Description |
|-----------|---------|-------------|
| Node versions | `[18, 20]` | Matrix of Node.js versions to test against |

**Triggers:** push to `main`, pull request to `main`

**Actions used:**
- `actions/checkout@v4`
- `actions/setup-node@v4`

---

### 4. Python CI (`python-ci.yml`)

Installs dependencies, lints with flake8, and runs pytest with coverage for the Flask app in `test/python/`.

| Parameter | Default | Description |
|-----------|---------|-------------|
| Python versions | `["3.11", "3.12"]` | Matrix of Python versions to test against |

**Triggers:** push to `main`, pull request to `main`

**Actions used:**
- `actions/checkout@v4`
- `actions/setup-python@v5`

---

### 5. Security Scan (`security-scan.yml`)

Runs Trivy in two modes: a filesystem scan of the entire repository and an image scan against `test/security/Dockerfile`. The Dockerfile intentionally uses `python:3.11-slim` so Trivy has something to flag.

| Parameter | Default | Description |
|-----------|---------|-------------|
| Severity (fs scan) | `CRITICAL,HIGH` | Minimum severity that causes a non-zero exit |
| Severity (image scan) | `CRITICAL,HIGH,MEDIUM` | Severities reported (does not fail the job) |

**Triggers:** push to `main`, weekly on Mondays at 09:00 UTC

**Actions used:**
- `actions/checkout@v4`
- `aquasecurity/trivy-action@0.24.0`

---

### 6. Terraform Plan (`terraform-plan.yml`)

Initializes Terraform, checks formatting, validates configuration, and runs `terraform plan` against the Docker provider config in `test/terraform/`. No cloud credentials are required because it uses the local Docker provider.

| Parameter | Default | Description |
|-----------|---------|-------------|
| Terraform version | `1.6.6` | Version installed by setup-terraform |

**Triggers:** push or pull request when `.tf` files in `test/terraform/` change

**Actions used:**
- `actions/checkout@v4`
- `hashicorp/setup-terraform@v3`

---

## Testing Locally with `act`

[`act`](https://github.com/nektos/act) lets you run GitHub Actions workflows on your machine using Docker.

### Prerequisites

- Docker running locally
- `act` installed (`brew install act` on macOS, or see the act docs)

### Running workflows

```bash
# Run a specific workflow
act -W .github/workflows/docker-build.yml

# Run on a specific event
act push -W .github/workflows/node-ci.yml

# Run with a larger runner image (needed for most workflows)
act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# List all available workflows
act -l
```

### Notes on local runs

- **Terraform plan** requires Docker to be available inside the runner container. Pass `--privileged` or bind-mount the Docker socket: `act -W .github/workflows/terraform-plan.yml --bind`
- **Helm lint** works out of the box since it only needs the Helm binary.
- **Security scan** builds a Docker image, so it also needs Docker-in-Docker or socket access.
- **Node and Python** workflows run the full matrix by default. Use `--matrix node-version:20` or `--matrix python-version:3.12` to run a single combination.

---

## Repository Structure

```
.github/workflows/       # Reusable workflow definitions
  docker-build.yml
  helm-lint-test.yml
  node-ci.yml
  python-ci.yml
  security-scan.yml
  terraform-plan.yml

test/                     # Minimal fixtures that each workflow targets
  docker/                 # Nginx container serving a static page
  helm/                   # Helm chart with deployment + service
  node/                   # Express app with Jest tests
  python/                 # Flask app with pytest tests
  security/               # Dockerfile with an older base image for Trivy
  terraform/              # Docker provider config (no cloud needed)
```

<sub><sup>Originally developed and tested locally during learning. Later organized and pushed to GitHub for portfolio visibility.</sup></sub>
