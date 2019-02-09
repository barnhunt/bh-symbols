.PHONY: default install

CONFIG_DIR   = ${HOME}/.config
INKSCAPE_DIR = ${CONFIG_DIR}/inkscape

default: install

install:
	rsync -ai --delete-after --filter ". install.filter" \
	    templates symbols ${INKSCAPE_DIR}

scrapbook.pdf: scrapbook.svg bind-scrapbook.sh
	bash bind-scrapbook.sh > $@
