from __future__ import annotations

import os
from dataclasses import asdict
from dataclasses import dataclass
from pathlib import Path
from typing import Final
from typing import IO
from typing import Literal
from typing import TYPE_CHECKING

from lxml import etree

if TYPE_CHECKING:
    from _typeshed import StrPath
    from lxml.etree import _ElementOrXMLTree


ROOT_PATH: Final = Path(__file__).parent
SRC_PATH: Final = ROOT_PATH / "src"


@dataclass
class BaleParams:
    length: int = 36
    width: int = 18
    height: int = 15
    strings: Literal[2, 3] = 2
    scale: int = 48

    def xslt_params(self) -> dict[str, str]:
        return {
            f"bale-{attr}": f"{value:d}"
            for attr, value in asdict(self).items()
        }


BALE_SIZES = [
    BaleParams(36, 18, 15),
    BaleParams(39, 18, 15),
    BaleParams(42, 18, 16),
    BaleParams(48, 18, 16),
    BaleParams(52, 18, 16),

    BaleParams(48, 24, 18, strings=3),
    BaleParams(45, 22, 16, strings=3),

    BaleParams(42, 18, 16, scale=60),
]


class XSLTransform:
    def __init__(self, xslt_path: StrPath):
        with Path(SRC_PATH, xslt_path).open("rb") as fp:
            xslt_doc = etree.parse(fp)
        self.set_output_encoding(xslt_doc, "utf-8")
        self.xslt = etree.XSLT(xslt_doc)

    def __call__(
        self, doc: etree._ElementOrXMLTree, **params: str
    ) -> etree._XSLTResultTree:
        return self.xslt(doc, **params)  # type: ignore[arg-type]

    @staticmethod
    def set_output_encoding(doc: _ElementOrXMLTree, encoding: str) -> None:
        output = doc.find("{http://www.w3.org/1999/XSL/Transform}output")
        assert output is not None
        output.attrib["encoding"] = encoding


fix_patterns = XSLTransform("fix-patterns.xslt")


class BaleGenerator:
    def __init__(
        self,
        root_path: StrPath = ROOT_PATH,
        xslt_path: StrPath = "bh-bales.xslt",
        svg_path: StrPath = "bh-bales.svg",
    ) -> None:
        self.root_path = Path(root_path)
        self.transform = XSLTransform(xslt_path)
        with Path(SRC_PATH, svg_path).open("rb") as fp:
            self.template = etree.parse(fp)

    def generate(self, fp: IO[bytes], bale_params: BaleParams) -> None:
        params = {
            f"bale-{attr}": f"{value:d}"
            for attr, value in asdict(bale_params).items()
        }
        result = self.transform(self.template, **params)
        result = fix_patterns(result)
        result.write_output(fp)  # type: ignore[attr-defined]

    def __call__(self, bale_params: BaleParams) -> str:
        output_fn = Path("bh_symbols", output_name(bale_params))
        with open(self.root_path / output_fn, "wb") as fp:
            self.generate(fp, bale_params)
        return os.fspath(output_fn)


def output_name(bale_params: BaleParams) -> str:
    dimensions = "{length:d}x{width:d}x{height:d}".format(
        **asdict(bale_params)
    )
    scale_suffix = (
        "" if bale_params.scale == 48 else f"-{bale_params.scale:d}to1"
    )
    return f"bh-bales-{dimensions}{scale_suffix}.svg"


def main() -> None:
    generator = BaleGenerator()
    for bale in BALE_SIZES:
        print(generator(bale))


if __name__ == "__main__":
    main()
