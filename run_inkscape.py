"""Run Inkscape for testing with symbols installed from source.
"""
from __future__ import annotations

import os
import random
import subprocess
import sys
import weakref
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Any
from typing import Callable
from typing import Iterable
from typing import TypeVar
from zipfile import ZipFile


class InkscapeRunner:
    _finalize: Callable[[], None] | None = None

    def __init__(self, tmp_path: str | Path | None = None):
        if tmp_path is None:
            tmp_dir = TemporaryDirectory(prefix="bh-symbols_")
            self._finalize = weakref.finalize(self, tmp_dir.cleanup)
            tmp_path = tmp_dir.name
        self.tmp_path = Path(tmp_path)

    Self = TypeVar("Self", bound="InkscapeRunner")

    def __enter__(self: Self) -> Self:
        return self

    def __exit__(self: Self, *args: Any) -> None:
        if self._finalize:
            self._finalize()

    @property
    def profile_path(self) -> Path:
        return self.tmp_path / "profile"

    def install_symbols(self) -> None:
        dist = self.tmp_path / "dist"
        subprocess.run(
            ("hatch", "build", "--target=zipped-directory", dist),
            check=True,
        )
        output = [p for p in dist.iterdir() if p.suffix == ".zip"]
        assert len(output) == 1
        ZipFile(output[0]).extractall(self.profile_path / "symbols")

    def run_inkscape(self, args: Iterable[str]) -> None:
        env = os.environ.copy()
        env["INKSCAPE_PROFILE_DIR"] = os.fspath(self.profile_path)
        inkscape = os.environ.get("INKSCAPE_COMMAND", "inkscape")
        cmd = (inkscape, "--app-id-tag", _random_app_id(), *args)
        subprocess.run(cmd, env=env)

    def __call__(self, args: Iterable[str]) -> None:
        self.install_symbols()
        self.run_inkscape(args)


def _random_app_id(len: int = 7):
    return f"t{random.randrange(16 ** len):0{len}x}"


if __name__ == "__main__":
    with InkscapeRunner() as runner:
        runner(sys.argv[1:])
