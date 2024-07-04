#!/usr/bin/make -f

SITE_REMOTE ?= www/
export SITE_TITLE ?= Fäktning/M5K i Falun
export SUBTITLE ?= En sektion i Dalregementets IF
KEYWORDS_BASE ?= fäktning, M5K, modern femkamp, värja, falun
SITE_RSYNC_OPTS ?= -O -e "ssh -i deploy_key"

.PHONY: help build deploy clean

SRC = src
IMG = data/img
TMPL = templates
#PAGES = $(shell git ls-tree HEAD --name-only -- $(SRC)/*.html 2>/dev/null)
PAGES = $(shell ls -1 -- $(SRC)/*.html 2>/dev/null)
IMAGES = $(shell ls -1 -- $(IMG)/*.png 2>/dev/null)

help:
	$(info make build|deploy|clean)

build: $(patsubst $(SRC)/%.html,build/%.html,$(PAGES)) \
	$(patsubst $(IMG)/%.png,build/img/%.png,$(IMAGES)) \
	build/js/calendar.js

deploy: build
	rsync -rLvzc $(SITE_RSYNC_OPTS) build/ data/ $(SITE_REMOTE)

clean:
	rm -rf build

build/%.html: $(SRC)/%.html $(SRC)/%.env $(addprefix $(TMPL)/,$(addsuffix .html,header banner footer))
	mkdir -p build
	export $(shell grep -v '^#' $(SRC)/$*.env | tr '\n' '\0' | xargs -0); \
	export KEYWORDS="$(KEYWORDS_BASE), $$KEYWORDS"; \
	[ -z "$$PAGE_TITLE" ] && TITLE="$(SITE_TITLE)" || TITLE="$$PAGE_TITLE · $(SITE_TITLE)"; \
	export TITLE; \
	[ -z "$$BANNER" ] && cp $(TMPL)/header.html $@.tmp1 || sed -e '/<!-- BANNER -->/{r $(TMPL)/banner.html' -e 'd}' $(TMPL)/header.html > $@.tmp1; \
	envsubst < $@.tmp1 > $@.tmp2; \
	rm $@.tmp1; \
	envsubst < $< >> $@.tmp2; \
	[ -z "$$SIDEIMAGE" ] || sed -i -e '/<!-- SIDEIMAGE -->/{r $(TMPL)/sideimage.html' -e 'd}' $@.tmp2; \
	[ -z "$$PAGETITLE" ] || sed -i -e 's#<!-- PAGETITLE -->#<h1>$$PAGE_TITLE</h1>#' $@.tmp2; \
	envsubst < $@.tmp2 > $@; \
	rm $@.tmp2; \
	envsubst < $(TMPL)/footer.html >> $@; \

build/img/%.png: $(IMG)/%.png
	mkdir -p build/img
	cp $(IMG)/$(@F) $@; \
	sh webp.sh $@; \

build/js/calendar.js: data/js/buildcalendar.js
	sh calendar.sh; \
