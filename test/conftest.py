import os
import subprocess
import time
from contextlib import contextmanager

import pytest

TAG = os.environ.get("TAG_VERSION", "")
ENGINE = os.environ.get("CONTAINER_ENGINE", "docker")


@pytest.fixture(scope="session", autouse=True)
def require_tag_version():
    if not TAG:
        pytest.exit("TAG_VERSION must be exported (run tests via `make test`)", returncode=2)


@pytest.fixture(scope="session")
def image():
    def _image(name):
        # fully qualified: podman refuses short names when it has no search registry to resolve them
        return f"docker.io/optionfactory/{name}:{TAG}"

    return _image


@pytest.fixture(scope="session")
def run(image):
    """Run a command in a fresh container of the given image, entrypoint-overridden."""

    def _run(image_name, *args, timeout=90):
        try:
            return subprocess.run(
                [ENGINE, "run", "--rm", "--entrypoint", args[0], image(image_name), *args[1:]],
                capture_output=True,
                text=True,
                timeout=timeout,
            )
        except subprocess.TimeoutExpired:
            return subprocess.CompletedProcess(args, 124, "", f"timeout after {timeout}s")

    return _run


@pytest.fixture(scope="session")
def boot(image):
    """Start a detached container with its real entrypoint; yields the container id."""

    @contextmanager
    def _boot(image_name, *docker_args):
        cid = subprocess.run(
            [ENGINE, "run", "-d", *docker_args, image(image_name)],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        try:
            yield cid
        finally:
            subprocess.run([ENGINE, "rm", "-f", "-v", cid], capture_output=True)

    return _boot
