.PHONY: default install symbols

VPATH = src

CONFIG_DIR   = ${HOME}/.config
INKSCAPE_DIR = ${CONFIG_DIR}/inkscape

default: install

install:
	rsync -ai --delete-after --filter ". install.filter" \
	    templates symbols extensions ${INKSCAPE_DIR}


make_bales = xsltproc \
	--param bale-length $(1) \
	--param bale-width $(2) \
	--param bale-height $(3) \
	--param bale-strings $(4) \
	--param bale-scale $(or $(5), 48) \
    src/bh-bales.xslt src/bh-bales.svg

symbols: symbols/bh-bales-36x18x15.svg
symbols/bh-bales-36x18x15.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 36, 18, 15, 2) > $@

symbols: symbols/bh-bales-39x18x15.svg
symbols/bh-bales-39x18x15.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 39, 18, 15, 2) > $@

symbols: symbols/bh-bales-42x18x16.svg
symbols/bh-bales-42x18x16.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 42, 18, 16, 2) > $@

symbols: symbols/bh-bales-48x18x16.svg
symbols/bh-bales-48x18x16.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 48, 18, 16, 2) > $@

symbols: symbols/bh-bales-48x24x18.svg
symbols/bh-bales-48x24x18.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 48, 24, 18, 3) > $@


# 42" 2-string bales at 60:1 (5 feet per inch) scale
symbols: symbols/bh-bales-42x18x16-60to1.svg
symbols/bh-bales-42x18x16-60to1.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 42, 18, 16, 2, 60) > $@
