from __future__ import annotations

import os
from pathlib import Path
from typing import Any
from typing import Iterable

from hatchling.builders.hooks.plugin.interface import BuildHookInterface

from build_symbols import SYMBOL_SETS


class CustomBuildHook(BuildHookInterface):  # type: ignore[misc]
    def clean(self, versions: Iterable[str]) -> None:
        bh_symbols = Path(self.root, "bh_symbols")
        if not bh_symbols.exists():
            return
        for file in bh_symbols.iterdir():
            if file.is_file():
                os.unlink(file)

    def initialize(self, version: str, build_data: dict[str, Any]) -> None:
        if self.target_name != "zipped-directory":
            raise RuntimeError(
                "This project only supports the 'zipped-directory' target"
            )

        artifacts = build_data.setdefault("artifacts", [])

        artifacts.extend(
            symbol_set.generate(self.root) for symbol_set in SYMBOL_SETS
        )
