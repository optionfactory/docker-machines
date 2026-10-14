"""Boot/integration tests: real entrypoints, readiness log lines, HTTP, running state."""

import subprocess
import time
import urllib.error
import urllib.request

import pytest

TOMCAT_PORT = 18084
CINNY_PORT = 18085


def logs_of(cid):
    result = subprocess.run(["docker", "logs", cid], capture_output=True, text=True)
    return result.stdout + result.stderr


def wait_for_log(cid, expected, timeout):
    deadline = time.monotonic() + timeout
    logs = ""
    while time.monotonic() < deadline:
        logs = logs_of(cid)
        if expected in logs:
            return logs
        time.sleep(1)
    return logs


def wait_for_no_new_privs(cid, timeout):
    """PID 1 is the root entrypoint until it execs the service through setpriv."""
    deadline = time.monotonic() + timeout
    status = ""
    while time.monotonic() < deadline:
        status = subprocess.run(["docker", "exec", cid, "grep", "NoNewPrivs", "/proc/1/status"], capture_output=True, text=True).stdout
        if status.split() == ["NoNewPrivs:", "1"]:
            return status
        time.sleep(1)
    return status


def listening_ports(cid):
    tables = subprocess.run(["docker", "exec", cid, "cat", "/proc/net/tcp", "/proc/net/tcp6"], capture_output=True, text=True).stdout
    rows = [line.split() for line in tables.splitlines()]
    return {int(row[1].rsplit(":", 1)[1], 16) for row in rows if len(row) > 3 and row[3] == "0A"}


def test_postgres_boots_and_accepts_connections(boot):
    with boot("debian13-postgres17") as cid:
        logs = wait_for_log(cid, "database system is ready to accept connections", 120)
        assert "database system is ready to accept connections" in logs, logs[-800:]
        status = wait_for_no_new_privs(cid, 30)
        assert status.split() == ["NoNewPrivs:", "1"], status


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


def test_caddy_binds_privileged_port_without_capabilities(boot):
    with boot("debian13-caddy2") as cid:
        logs = wait_for_log(cid, "serving initial configuration", 30)
        assert "serving initial configuration" in logs, logs[-800:]
        assert 80 in listening_ports(cid), logs[-800:]
        status = wait_for_no_new_privs(cid, 10)
        assert status.split() == ["NoNewPrivs:", "1"], status


def test_sloth_keeps_running(boot):
    with boot("sloth") as cid:
        time.sleep(3)
        state = subprocess.run(
            ["docker", "inspect", "-f", "{{.State.Running}}", cid],
            capture_output=True,
            text=True,
        ).stdout.strip()
        assert state == "true", f"sloth exited early:\n{logs_of(cid)[-800:]}"


def test_cinny_serves_the_client_and_falls_back_to_index(boot):
    with boot("debian13-nginx130-cinny4", "-p", f"{CINNY_PORT}:8080") as cid:
        deadline = time.monotonic() + 30
        last_error = None
        while time.monotonic() < deadline:
            try:
                for path in ("/", "/config.json", "/home/some/client/route"):
                    with urllib.request.urlopen(f"http://localhost:{CINNY_PORT}{path}", timeout=2) as response:
                        assert response.status == 200, path
                return
            except urllib.error.URLError as error:  # connection refused while starting
                last_error = error
                time.sleep(1)
        pytest.fail(f"cinny never answered: {last_error}\n{logs_of(cid)[-800:]}")


def test_step_ca_inits_and_serves(image):
    volume = subprocess.run(["docker", "volume", "create"], capture_output=True, text=True, check=True).stdout.strip()
    try:
        init = subprocess.run(
            ["docker", "run", "--rm", "-v", f"{volume}:/opt/step-ca/data", "--entrypoint", "bash", image("debian13-step-ca0"), "-c",
             "mkdir -p /opt/step-ca/data/secrets && echo test > /opt/step-ca/data/secrets/password"
             " && chown -R step-ca:docker-machines /opt/step-ca/data"
             " && step ca init --ssh --deployment-type=standalone --name=test --dns=localhost --address=:9000"
             " --provisioner=admin --password-file=/opt/step-ca/data/secrets/password"
             " --provisioner-password-file=/opt/step-ca/data/secrets/password"],
            capture_output=True,
            text=True,
            timeout=60,
        )
        assert init.returncode == 0, init.stdout + init.stderr
        cid = subprocess.run(
            ["docker", "run", "-d", "-v", f"{volume}:/opt/step-ca/data", image("debian13-step-ca0")],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        try:
            logs = wait_for_log(cid, "Serving HTTPS on :9000", 30)
            assert "Serving HTTPS on :9000" in logs, logs[-800:]
            status = wait_for_no_new_privs(cid, 10)
            assert status.split() == ["NoNewPrivs:", "1"], status
            health = subprocess.run(["docker", "exec", cid, "step", "ca", "health", "--ca-url", "https://localhost:9000",
                                     "--root", "/opt/step-ca/data/certs/root_ca.crt"], capture_output=True, text=True)
            assert health.stdout.strip() == "ok", health.stdout + health.stderr
        finally:
            subprocess.run(["docker", "rm", "-f", cid], capture_output=True)
    finally:
        subprocess.run(["docker", "volume", "rm", volume], capture_output=True)
