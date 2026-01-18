# Nix files to check (can be files, directories, or patterns)

nix-files := "."
docker-image := "nixos-setup-helper"

# Command to run nix in Docker with flakes enabled

nix-docker-base := """
    docker run --rm \
        -t \
        --platform=linux/$(uname -m) \
        --security-opt seccomp=unconfined \
        -v "$(pwd)":/etc/nixos \
        -w /etc/nixos \
        """
nix-docker := nix-docker-base + docker-image + " "

# Default target
[default]
[private]
default:
    @just --list

[doc('Format Nix code with nixfmt')]
format: (run-nixfmt nix-files)

[doc('Run nix flake checks locally or in Docker if nix is not installed')]
lint: (run-nixfmt "--check" nix-files)

# Helper function to run a command locally or in Docker if not installed
[private]
run-local-or-docker docker cmd *args:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v {{ cmd }} >/dev/null 2>&1; then
        {{ cmd }} {{ args }}
    else
        just build-docker-image
        {{ docker }} {{ cmd }} {{ args }}
    fi

# Helper function to run nix commands locally or in Docker
[private]
run-nix *args: (run-local-or-docker nix-docker "nix" args)

# Helper function to run nixfmt commands locally or in Docker
[private]
run-nixfmt *args: (run-local-or-docker nix-docker "nixfmt" args)

# Helper function to build docker image
[private]
build-docker-image:
    docker build -t {{ docker-image }} docker
