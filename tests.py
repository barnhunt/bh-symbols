import re
from pathlib import Path
from typing import Counter
from typing import TYPE_CHECKING
from typing import TypeAlias

import pytest
from lxml import etree

from build_symbols import SYMBOL_SETS

if TYPE_CHECKING:
    ETree: TypeAlias = etree._ElementTree[etree._Element]
else:
    ETree = object


SVG_SYMBOL = "{http://www.w3.org/2000/svg}symbol"
XLINK_HREF = "{http://www.w3.org/1999/xlink}href"


@pytest.fixture(scope="session")
def symbol_path(tmp_path_factory: pytest.TempPathFactory) -> Path:
    """Build symbols

    Return path to directory containing symbol SVG files.
    """
    root_path = tmp_path_factory.mktemp("root_path")
    for symbol_set in SYMBOL_SETS:
        symbol_set.generate(root_path=root_path)
    return root_path / "bh_symbols"


SYMBOL_FILENAMES = tuple(symbol_set.output_name for symbol_set in SYMBOL_SETS)


@pytest.fixture(scope="function", params=SYMBOL_FILENAMES)
def symbol_tree(symbol_path: Path, request: pytest.FixtureRequest) -> ETree:
    output_name: str = request.param
    with open(symbol_path / output_name, "rb") as fp:
        return etree.parse(fp)


def test_dangling_hrefs(symbol_tree: ETree) -> None:
    defined_ids = set(
        elem.get("id") for elem in symbol_tree.iterfind("//*[@id]")
    )

    for elem in symbol_tree.iterfind(f"//*[@{XLINK_HREF}]"):
        href = elem.get(XLINK_HREF)
        assert href is not None
        assert href.startswith("#")
        assert href[1:] in defined_ids


def test_dangling_url_refs(symbol_tree: ETree) -> None:
    defined_ids = set(
        elem.get("id") for elem in symbol_tree.iterfind("//*[@id]")
    )

    for elem in symbol_tree.iter():
        for attr, attr_val in elem.attrib.items():
            for url in re.findall(r"\burl\((.*?)\)", attr_val):
                print(attr, url)
                assert url.startswith("#")
                assert url[1:] in defined_ids


def test_ids_unique(symbol_tree: ETree) -> None:
    id_counter = Counter(
        elem.get("id") for elem in symbol_tree.iterfind("//*[@id]")
    )
    assert all(count == 1 for count in id_counter.values())


global_symbol_id_counter: Counter[str] = Counter()


def test_globally_unique_symbol_ids(symbol_tree: ETree) -> None:
    for elem in symbol_tree.iterfind(f"//{SVG_SYMBOL}[@id]"):
        id = elem.get("id")
        assert id is not None
        global_symbol_id_counter[id] += 1
        assert global_symbol_id_counter[id] == 1, f"id {id!r}"
