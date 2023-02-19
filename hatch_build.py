from __future__ import annotations

import os
from pathlib import Path
from typing import Any
from typing import Iterable

from hatchling.builders.hooks.plugin.interface import BuildHookInterface

from build_bales import BaleGenerator, BALE_SIZES


class CustomBuildHook(BuildHookInterface):  # type: ignore[misc]
    def clean(self, versions: Iterable[str]) -> None:
        for file in Path(self.root, "bh_symbols").iterdir():
            if file.name.startswith("bh-bales-") and file.is_file():
                os.unlink(file)

    def initialize(self, version: str, build_data: dict[str, Any]) -> None:
        if self.target_name != "zipped-directory":
            raise RuntimeError(
                "This project only supports the 'zipped-directory' target"
            )

        artifacts = build_data.setdefault("artifacts", [])

        generate_bales = BaleGenerator(root_path=self.root)
        artifacts.extend(generate_bales(bale_size) for bale_size in BALE_SIZES)
