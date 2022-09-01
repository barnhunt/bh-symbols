
.PHONY: default install symbols

default: symbols

ifndef INKSCAPE_COMMAND
INKSCAPE_COMMAND = inkscape
endif

USER_DATA_DIR := $(shell "${INKSCAPE_COMMAND}" --user-data-directory | tail -n 1)

install:
ifdef USER_DATA_DIR
# Inkscape >= 1.0
	rsync --archive --itemize-changes --delete-after --exclude "*~" \
	    bh_symbols "${USER_DATA_DIR}/symbols"
else
	rsync --archive --itemize-changes --delete-after --exclude "*~" \
	    bh_symbols/ "${HOME}/.config/inkscape/symbols"
endif

VPATH = src

make_bales = xsltproc \
	--param bale-length $(1) \
	--param bale-width $(2) \
	--param bale-height $(3) \
	--param bale-strings $(4) \
	--param bale-scale $(or $(5), 48) \
    src/bh-bales.xslt src/bh-bales.svg

symbols: bh_symbols/bh-bales-36x18x15.svg
bh_symbols/bh-bales-36x18x15.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 36, 18, 15, 2) > $@

symbols: bh_symbols/bh-bales-39x18x15.svg
bh_symbols/bh-bales-39x18x15.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 39, 18, 15, 2) > $@

symbols: bh_symbols/bh-bales-42x18x16.svg
bh_symbols/bh-bales-42x18x16.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 42, 18, 16, 2) > $@

symbols: bh_symbols/bh-bales-48x18x16.svg
bh_symbols/bh-bales-48x18x16.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 48, 18, 16, 2) > $@

symbols: bh_symbols/bh-bales-52x18x16.svg
bh_symbols/bh-bales-52x18x16.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 52, 18, 16, 2) > $@

symbols: bh_symbols/bh-bales-48x24x18.svg
bh_symbols/bh-bales-48x24x18.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 48, 24, 18, 3) > $@

symbols: bh_symbols/bh-bales-45x22x16.svg
bh_symbols/bh-bales-45x22x16.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 45, 22, 16, 3) > $@


# 42" 2-string bales at 60:1 (5 feet per inch) scale
symbols: bh_symbols/bh-bales-42x18x16-60to1.svg
bh_symbols/bh-bales-42x18x16-60to1.svg: bh-bales.svg bh-bales.xslt
	$(call make_bales, 42, 18, 16, 2, 60) > $@
