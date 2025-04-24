# ──────────────────────────────────────────────────────────────────────────────
#  Makefile for gremlin‑boshrelease
# ──────────────────────────────────────────────────────────────────────────────

# Base version (bumped whenever you want to cut a final release)
VERSION    := $(shell cat VERSION)

# A timestamp for dev releases
TIMESTAMP  := $(shell date +%Y%m%d%H%M%S)

# Dev release version & tarball
DEV_VER    := $(VERSION)-dev.$(TIMESTAMP)
DEV_TGZ    := gremlin-$(DEV_VER).tgz

.PHONY: ver blobs cut_release upload final all

ver:
	@echo "→ gremlin release version is $(VERSION)"

blobs:
	@echo "→ preparing blobs directory"
	@mkdir -p blobs/gremlin

	@echo "→ running blob prep"
	@scripts/prepare-gremlin-blobs.sh

	@echo "→ cleaning up old BOSH blob mappings"
	-@bosh remove-blob gremlin.tar.gz    2>/dev/null || true
	-@bosh remove-blob gremlind.tar.gz   2>/dev/null || true

	@echo "→ re‑adding blobs at package root"
	bosh add-blob blobs/gremlin/gremlin.tar.gz  gremlin/gremlin.tar.gz
	bosh add-blob blobs/gremlin/gremlind.tar.gz gremlin/gremlind.tar.gz

# Dev release: timestamped so it never conflicts
cut_release: blobs
	@echo "→ creating dev release gremlin/$(DEV_VER)"
	bosh create-release \
	  --force \
	  --version=$(DEV_VER) \
	  --tarball=$(DEV_TGZ)

upload: cut_release
	@echo "→ uploading $(DEV_TGZ)"
	bosh upload-release $(DEV_TGZ)

# Final release: uses exactly the VERSION in your file—bump VERSION when you're ready
final: blobs
	@echo "→ creating FINAL release gremlin/$(VERSION)"
	bosh create-release \
	  --final \
	  --force \
	  --version=$(VERSION) \
	  --tarball=gremlin-$(VERSION).tgz

all: ver


