#!/usr/bin/make -f

SITE_REMOTE ?= www/
export SITE_TITLE ?= Fäktning/M5K i Falun
export SUBTITLE ?= En sektion i Dalregementets IF
KEYWORDS_BASE ?= fäktning, M5K, modern femkamp, värja, falun
SITE_RSYNC_OPTS ?= -O -e "ssh -i deploy_key"

.PHONY: help build deploy clean

SRC = src
IMG = data/img
export TMPL = templates
#PAGES = $(shell git ls-tree HEAD --name-only -- $(SRC)/*.html 2>/dev/null)
PAGES = $(shell ls -1 -- $(SRC)/*.txt 2>/dev/null)

help:
	$(info make build|deploy|clean)

build: $(patsubst $(SRC)/%.txt,build/%.html,$(PAGES)) \
	build/img \
	build/js/calendar.js

deploy: build
	rsync -rLvzc $(SITE_RSYNC_OPTS) build/ data/ $(SITE_REMOTE)

clean:
	rm -rf build

build/%.html: $(SRC)/%.txt $(addprefix $(TMPL)/,$(addsuffix .html,header banner footer))
	sh build.sh "$(SRC)/$(*).txt" "$(@)"

build/img:
	sh img.sh $(IMG)

build/js/calendar.js: data/js/buildcalendar.js
	sh calendar.sh; \
