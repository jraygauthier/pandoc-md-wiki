MKF_CWD := $(shell pwd)

.PHONY: all clean tests

all: typechecks tests lint release

clean:
	rm -f ./result*

static-checks: typechecks lint

typechecks:
	mypy ./src $(shell find ./tests -name "test_*.py")

tests:
	pytest

lint:
	flake8

release:
	nix-build release.nix -A default

shell.dev:
	nix-shell release.nix -A shell.dev

shell.installed:
	nix-shell release.nix -A shell.installed