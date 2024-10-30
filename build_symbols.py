from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Final
from typing import Literal
from typing import TYPE_CHECKING
from typing import TypeAlias

from lxml import etree

if TYPE_CHECKING:
    from _typeshed import StrPath
    from lxml.etree import _ElementOrXMLTree
    from lxml.etree import _XSLTQuotedStringParam
    _ETree: TypeAlias = etree._ElementTree[etree._Element]
else:
    _ETree = None


ROOT_PATH: Final = Path(__file__).parent
SRC_PATH: Final = ROOT_PATH / "src"
OUTPUT_BASE: Final = Path("bh_symbols")


class XSLTransform:
    def __init__(self, xslt_path: StrPath):
        xslt_doc = etree.parse(SRC_PATH / xslt_path)
        self.set_output_encoding(xslt_doc, "utf-8")
        self.xslt = etree.XSLT(xslt_doc)

    def __call__(
        self,
        doc: etree._ElementOrXMLTree,
        **params: str | _XSLTQuotedStringParam,
    ) -> etree._XSLTResultTree:
        return self.xslt(doc, **params)  # type: ignore[arg-type]

    @staticmethod
    def set_output_encoding(doc: _ElementOrXMLTree, encoding: str) -> None:
        output = doc.find("{http://www.w3.org/1999/XSL/Transform}output")
        assert output is not None
        output.attrib["encoding"] = encoding


@dataclass
class SymbolSet:
    src_file: str
    scale: int = 48

    transform_xslt: str = "bh-bales.xslt"
    fixer_xslt: str = "fix-patterns.xslt"

    src_path: Path = SRC_PATH
    output_base: Path = OUTPUT_BASE

    @property
    def output_name(self) -> str:
        path = Path(self.src_file)
        if self.scale != 48:
            path = path.with_stem(f"{path.stem}-{self.scale:d}to1")
        return str(path)

    def xslt_params(self) -> dict[str, str]:
        return {"bale-scale": f"{self.scale:d}"}

    def etree(self) -> _ETree:
        doc = etree.parse(self.src_path / self.src_file)
        xslt = XSLTransform(self.src_path / self.transform_xslt)
        return xslt(doc, **self.xslt_params())

    def generate(
        self,
        root_path: Path = ROOT_PATH,
        package_name: str = "",
        package_version: str = "",
    ) -> str:
        strparam = etree.XSLT.strparam
        fixer_params = {
            "package-name": strparam(package_name),
            "package-version": strparam(package_version),
        }

        svg = self.etree()
        fixer = XSLTransform(self.src_path / self.fixer_xslt)
        result = fixer(svg, **fixer_params)

        output_path = self.output_base / self.output_name
        output_file = root_path / output_path
        output_file.parent.mkdir(parents=True, exist_ok=True)
        with open(output_file, "wb") as fp:
            result.write_output(fp)
        return os.fspath(output_path)


@dataclass
class BaleSet(SymbolSet):
    length: int = 36
    width: int = 18
    height: int = 15
    strings: Literal[2, 3] = 2

    src_file: str = "bh-bales.svg"

    def xslt_params(self) -> dict[str, str]:
        return {
            f"bale-{attr}": f"{getattr(self, attr):d}"
            for attr in ("length", "width", "height", "strings", "scale")
        }

    @property
    def output_name(self) -> str:
        dimensions = f"{self.length:d}x{self.width:d}x{self.height:d}"
        if self.scale != 48:
            dimensions += f"-{self.scale:d}to1"
        return f"bh-bales-{dimensions}.svg"


BALE_SIZES = [
    {"length": 36, "width": 18, "height": 15},
    {"length": 39, "width": 18, "height": 15},
    {"length": 42, "width": 18, "height": 16},
    {"length": 45, "width": 18, "height": 16},
    {"length": 48, "width": 18, "height": 16},
    {"length": 52, "width": 18, "height": 16},
    {"length": 48, "width": 24, "height": 18, "strings": 3},
    {"length": 45, "width": 22, "height": 16, "strings": 3},
]


SYMBOL_SETS = [
    SymbolSet("bh-rings.svg"),
    SymbolSet("bh-bits.svg"),
    SymbolSet("bh-bits.svg", scale=60),
    *(
        BaleSet(**size, **scale)
        for size in BALE_SIZES
        for scale in ({}, {"scale": 60})
    ),
]


def main() -> None:
    for symbol_set in SYMBOL_SETS:
        print(symbol_set.generate())


if __name__ == "__main__":
    main()
