# gremlin-boshrelease

# 1. Initialize the release scaffold
bosh init-release --name gremlin --dir .

# 2. Generate your single “gremlin” package
bosh generate-package gremlin

# 3. Generate the gremlind job
bosh generate-job gremlind

# 4. Pull in your pre‑built binaries as blobs
#    (adjust paths to where you built the .tgz’s)
bosh add-blob /path/to/gremlin_2.XX.0_amd64.tgz   blobs/gremlin/gremlin.tar.gz
bosh add-blob /path/to/gremlind_2.XX.0_amd64.tgz  blobs/gremlin/gremlind.tar.gz

# 5. Copy in all of the spec + template files:
#    - packages/gremlin/spec       ← the YAML from step 1 above
#    - jobs/gremlind/spec          ← the job spec from step 2 above
#    - jobs/gremlind/templates/**  ← your .erb files (pre-start.sh, config.yaml.erb, start.sh, stop.sh)

# 6. Build & upload your release
bosh create-release --force --tarball=gremlin-0.1.0.tgz
bosh upload-release gremlin-0.1.0.tgz
