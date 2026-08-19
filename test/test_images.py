"""Version and content checks: params are sourced from checks.toml (one
[[check]] table per assertion, stdlib tomllib), every image is exercised through
its real binaries. Assertions are major-version level so routine pin bumps don't
break the suite."""

import tomllib
from dataclasses import dataclass
from pathlib import Path

import pytest


@dataclass(frozen=True)
class Check:
    image: str
    command: tuple
    expect: str
    id: str = ""

    @property
    def test_id(self):
        return self.id or self.image


def load_checks():
    rows = tomllib.loads((Path(__file__).parent / "checks.toml").read_text())["check"]
    return [Check(command=tuple(row["command"]), **{k: v for k, v in row.items() if k != "command"}) for row in rows]


@pytest.mark.parametrize("check", [pytest.param(c, id=c.test_id) for c in load_checks()])
def test_image_content(run, check):
    result = run(check.image, *check.command)
    output = result.stdout + result.stderr
    assert result.returncode == 0, f"exit {result.returncode}\n{output[:800]}"
    assert check.expect in output, f"expected {check.expect!r} not found in:\n{output[:800]}"
