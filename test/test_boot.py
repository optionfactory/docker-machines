"""Boot/integration tests: real entrypoints, readiness log lines, HTTP, running state."""

import subprocess
import time
import urllib.error
import urllib.request

import pytest

TOMCAT_PORT = 18084


def logs_of(cid):
    return subprocess.run(["docker", "logs", cid], capture_output=True, text=True).stdout


def wait_for_log(cid, expected, timeout):
    deadline = time.monotonic() + timeout
    logs = ""
    while time.monotonic() < deadline:
        logs = logs_of(cid)
        if expected in logs:
            return logs
        time.sleep(1)
    return logs


def test_postgres_boots_and_accepts_connections(boot):
    with boot("debian13-postgres17", "-e", "POSTGRES_PASSWORD=test") as cid:
        logs = wait_for_log(cid, "database system is ready to accept connections", 120)
        assert "database system is ready to accept connections" in logs, logs[-800:]


def test_tomcat_serves_http(boot):
    with boot("debian13-jdk25-tomcat11", "-p", f"{TOMCAT_PORT}:8084") as cid:
        deadline = time.monotonic() + 60
        last_error = None
        while time.monotonic() < deadline:
            try:
                urllib.request.urlopen(f"http://localhost:{TOMCAT_PORT}/", timeout=2)
                return  # 200: something is deployed at root and answering
            except urllib.error.HTTPError as error:
                assert error.code == 404, f"unexpected http status: {error.code}"
                return  # connector up, no root webapp deployed: expected
            except Exception as error:  # connection refused while starting
                last_error = error
                time.sleep(1)
        pytest.fail(f"tomcat never answered: {last_error}\n{logs_of(cid)[-800:]}")


def test_sloth_keeps_running(boot):
    with boot("sloth") as cid:
        time.sleep(3)
        state = subprocess.run(
            ["docker", "inspect", "-f", "{{.State.Running}}", cid],
            capture_output=True,
            text=True,
        ).stdout.strip()
        assert state == "true", f"sloth exited early:\n{logs_of(cid)[-800:]}"
