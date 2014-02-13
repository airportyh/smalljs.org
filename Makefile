CONTENTSDIR = contents
BUILDDIR = build
IMAGESDIR = images
SRC_MD_FILES = $(shell find $(CONTENTSDIR) -name "*.md")
DST_HTML_FILES = $(shell echo $(subst $(CONTENTSDIR)/, $(BUILDDIR)/, $(SRC_MD_FILES:%.md=%.html)) | tr A-Z a-z)
SRC_IMAGES := $(shell find ${CONTENTSDIR} -name '*.png')
DST_IMAGES := $(shell echo $(subst $(CONTENTSDIR)/, $(BUILDDIR)/, $(SRC_IMAGES)) | tr A-Z a-z)
SRC_JS_FILES := $(shell find ${CONTENTSDIR} -name '*.js')
DST_JS_FILES := $(shell echo $(subst $(CONTENTSDIR)/, $(BUILDDIR)/, $(SRC_JS_FILES)) | tr A-Z a-z)
SRC_CSS_FILES := $(shell find ${CONTENTSDIR} -name '*.css')
DST_CSS_FILES := $(shell echo $(subst $(CONTENTSDIR)/, $(BUILDDIR)/, $(SRC_CSS_FILES)) | tr A-Z a-z)

all: $(DST_HTML_FILES) \
	$(BUILDDIR)/style.css \
	$(BUILDDIR)/smalljs.png \
	$(DST_IMAGES) \
	$(BUILDDIR)/index.html \
	$(DST_JS_FILES) \
	$(DST_CSS_FILES) \
	$(BUILDDIR)/feed.xml

$(BUILDDIR)/%/index.html: $(CONTENTSDIR)/%/index.md template.html bin/build_post
	mkdir -p $(addprefix $(BUILDDIR)/, $*)
	bin/build_post $< $@

$(BUILDDIR)/%.png: $(CONTENTSDIR)/%.png
	mkdir -p $(dir $@)
	cp $< $@

$(BUILDDIR)/%.js: $(CONTENTSDIR)/%.js
	mkdir -p $(dir $@)
	cp $< $@

$(BUILDDIR)/%.css: $(CONTENTSDIR)/%.css
	mkdir -p $(dir $@)
	cp $< $@

$(BUILDDIR)/index.html: index.html bin/build_index $(SRC_MD_FILES)
	bin/build_index

$(BUILDDIR)/feed.xml: feed.xml bin/build_feed $(SRC_MD_FILES)
	bin/build_feed

$(BUILDDIR)/style.css: style.css
	cp style.css $(BUILDDIR)/style.css

$(BUILDDIR)/smalljs.png: $(IMAGESDIR)/smalljs.png
	cp $< $@

clean:
	rm -fr build/*

debug:
	@echo $(DST_CSS_FILES)
	

