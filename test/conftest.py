import os
import subprocess
import time
from contextlib import contextmanager

import pytest

TAG = os.environ.get("TAG_VERSION", "")


@pytest.fixture(scope="session", autouse=True)
def require_tag_version():
    if not TAG:
        pytest.exit("TAG_VERSION must be exported (run tests via `make test`)", returncode=2)


@pytest.fixture(scope="session")
def image():
    def _image(name):
        return f"optionfactory/{name}:{TAG}"

    return _image


@pytest.fixture(scope="session")
def run(image):
    """Run a command in a fresh container of the given image, entrypoint-overridden."""

    def _run(image_name, *args, timeout=90):
        try:
            return subprocess.run(
                ["docker", "run", "--rm", "--entrypoint", args[0], image(image_name), *args[1:]],
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
            ["docker", "run", "-d", *docker_args, image(image_name)],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        try:
            yield cid
        finally:
            subprocess.run(["docker", "rm", "-f", cid], capture_output=True)

    return _boot
