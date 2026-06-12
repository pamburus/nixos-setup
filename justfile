# Nix files to check (can be files, directories, or patterns)

set lazy

nix-files := "."
docker-image := "nixos-setup-helper"

# Target machine hostname or SSH alias
host := "nixos"

# Helper variables for packing tracked files
just := just_executable()

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

[doc('Update flake.lock locally using Docker')]
update: (run-nix "flake" "update")

[doc('Deploy configuration to the target machine and copy back flake.lock')]
[script]
deploy:
    "{{ just }}" git-ls-poi | "{{ just }}" tar-for-linux | ssh "{{ host }}" \
        ' \
        set -euo pipefail && \
        sudo rm -rf /tmp/nixos-config && \
        sudo mkdir -p /tmp/nixos-config && \
        sudo tar x -C /tmp/nixos-config && \
        sudo rsync -a --delete --itemize-changes --chown=root:root /tmp/nixos-config/ /etc/nixos/ | (grep -E "^[<>ch][f]|^\*deleting" || true) && \
        sudo rm -rf /tmp/nixos-config && \
        sudo nixos-rebuild switch --flake /etc/nixos#nixos --show-trace \
        '
    scp -p {{ host }}:/etc/nixos/flake.lock .

[doc('Format Nix code with nixfmt')]
format: (run-nixfmt nix-files)

[doc('Run nix flake checks locally or in Docker if nix is not installed')]
lint: (run-nixfmt "--check" nix-files)

# Helper function to run a command locally or in Docker if not installed
[private]
[script]
run-local-or-docker docker cmd *args:
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

[private]
filter-existing-files:
    @xargs -n1 "{{ just }}" echo-if-file-exists

[private]
echo-if-file-exists filename:
    @test -f "{{ filename }}" && echo "{{ filename }}" || true

[private]
git-ls-poi:
    @git ls-files --cached --others --exclude-standard . | "{{ just }}" filter-existing-files

[private]
tar-for-linux:
    @COPYFILE_DISABLE=1 tar -c --no-xattrs -T -
