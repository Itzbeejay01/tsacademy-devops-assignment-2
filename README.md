# TS Academy DevOps Assignment 2

## Dockerized Diagnostic CLI

This repository contains my solution for **Assignment 2 — Dockerized Diagnostic CLI** from the TS Academy DevOps practical assignment.

The project packages a Bash-based diagnostic command-line tool in a lightweight Docker image. It provides system, network, disk, and help commands, includes local Docker tests, and can also be run with Docker Compose.

## Project Structure

```text
.
├── README.md
├── app/
│   ├── diagnostic.sh
│   └── health-check.sh
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── test.sh
└── grade.sh
```

## Requirements

- Docker with the `docker` CLI
- Docker Compose v2 for Compose commands
- Bash is required only when running the local test/grading scripts directly

## CLI Commands

```text
diagnostic system
diagnostic network <host>
diagnostic disk
diagnostic help
```

Exit codes:

- `0` — success
- `1` — operational/runtime failure
- `2` — invalid command or input

## Build the Image

```bash
docker build -t diagnostic-tool .
```

## Run with Docker

### Help

```bash
docker run --rm diagnostic-tool help
```

### System information

```bash
docker run --rm diagnostic-tool system
```

### Disk information

```bash
docker run --rm diagnostic-tool disk
```

### Network check

```bash
docker run --rm diagnostic-tool network example.com
```

## Run with Docker Compose

```bash
docker compose run --rm diagnostic help
docker compose run --rm diagnostic system
docker compose run --rm diagnostic disk
docker compose run --rm diagnostic network example.com
```

## Testing

The test suite builds a temporary Docker image and checks the required CLI behaviour:

```bash
chmod +x test.sh app/*.sh
./test.sh
```

The tests cover:

- `help`
- `system`
- `disk`
- invalid command handling

## Local Grading

Run the supplied assignment grader:

```bash
chmod +x grade.sh test.sh app/*.sh
./grade.sh
```

The grader validates the repository structure, Bash syntax, executable permissions, Dockerfile, Docker image build, CLI commands, invalid command handling, Compose configuration, and the student test suite.

## Docker Design Notes

The image uses Alpine Linux to keep the image small. Only packages required by the diagnostic scripts are installed. The application is copied into `/app`, scripts are made executable, and `diagnostic.sh` is configured as the container entrypoint.

The `.dockerignore` file excludes Git metadata, temporary files, logs, and other local files that are not required in the build context.

## Assumptions

- The assignment is graded on a machine with Docker available.
- Network checks depend on DNS and network availability at runtime.
- No cloud deployment is required for this assignment.
