SRC_MD_FILES = $(shell find contents -name "*.md")
DST_HTML_FILES = $(shell echo $(subst contents/, build/, $(SRC_MD_FILES:%.md=%.html)) | tr A-Z a-z)
SRC_ASSET_FILES := $(shell find contents -name '*.png' -o -name '*.js' -o -name '*.css' -o -name '*.jpg')
DST_ASSET_FILES := $(shell echo $(subst contents/, build/, $(SRC_ASSET_FILES)) | tr A-Z a-z)

all: \
	build/style.css \
	build/smalljs.png \
	build/index.html \
	$(DST_HTML_FILES) \
	$(DST_ASSET_FILES) \
	build/feed.xml

build/%/index.html: contents/%/index.md templates/post.html bin/build_post
	mkdir -p $(addprefix build/, $*)
	node bin/build_post $< $@

build/index.html: templates/index.html bin/build_index $(SRC_MD_FILES)
	node bin/build_index

build/feed.xml: templates/feed.xml bin/build_feed $(SRC_MD_FILES)
	node bin/build_feed

build/%: contents/%
	mkdir -p $(dir $@)
	cp $< $@

build/style.css: css/style.css
	cp $< $@

build/smalljs.png: images/smalljs.png
	cp $< $@

clean:
	rm -fr build/*

debug:
	@echo $(SRC_ASSET_FILES)
	

