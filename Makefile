.PHONY: blobs release upload

blobs:
	scripts/prepare-gremlin-blobs.sh
	bosh add-blob blobs/gremlin/gremlin.tar.gz    gremlin/gremlin.tar.gz
	bosh add-blob blobs/gremlin/gremlind.tar.gz   gremlin/gremlind.tar.gz

release: blobs
	bosh create-release --force --tarball=gremlin-0.1.0.tgz

upload: release
	bosh upload-release gremlin-0.1.0.tgz

