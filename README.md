# gremlin-boshrelease

A BOSH release for the Gremlin Chaos Engineering client (`gremlin`) and daemon (`gremlind`).  
Use this release to deploy Gremlin into any BOSH-managed environment (e.g. Cloud Foundry Diego cells).

---

## 📂 Repository Layout

```
.
├── VERSION                      # current release version
├── Makefile                     # helpers for building & uploading releases
├── config/
│   ├── blobs.yml                # blobstore config for `bosh create-release`
│   ├── vars.yaml                # dev ops-file variables
│   └── final.yml                # final ops-file variables
├── scripts/
│   └── prepare-gremlin-blobs.sh # download & extract upstream .deb packages
├── blobs/gremlin/               # local blobstore (gitignored)
├── packages/gremlin/            # gremlin CLI package spec
├── jobs/gremlind/               # gremlind job spec, Monit config & templates
└── operations/                  # example ops-files (e.g. for cf-deployment)
```

---

## 🚀 Getting Started

### Prerequisites

- [BOSH CLI v2](https://bosh.io/docs/cli-v2)
- A live BOSH Director and creds
- Internet access to `https://deb.gremlin.com/`

### 1. Prepare the blobs

```bash
make blobs
```

Downloads the latest `gremlin` & `gremlind` `.deb` packages and stages their binaries under `blobs/gremlin/`.

### 2. Cut a **dev** release

```bash
make cut_release
```

Builds `gremlin-$(cat VERSION)-dev.$(date +%Y%m%d%H%M%S).tgz`.

### 3. Upload the **dev** release

```bash
make upload
```

Runs `bosh upload-release` for the freshly built tarball.

### 4. Cut & upload a **final** release

1. Bump `VERSION` to your target (e.g. `1.2.3`).
2. Run:

   ```bash
   make final
   bosh upload-release gremlin-$(cat VERSION).tgz
   ```

---

## 🎯 Using in Your BOSH Deployment

1. **Add** the release to your manifest:

   ```yaml
   releases:
   - name: gremlin
     version: ((release_version))
   ```

2. **Wire in** the `gremlind` job:

   ```yaml
   instance_groups:
   - name: diego-cell
     jobs:
     - name: gremlind
       release: gremlin
       properties:
         gremlin:
           team_id:            ((gremlin.team_id))
           team_certificate:   ((gremlin.team_certificate))
           team_private_key:   ((gremlin.team_private_key))
           tags:               ((gremlin.tags))
   ```

3. **Deploy** with your variables:

   ```bash
   bosh -e <env> -d <deployment> deploy manifest.yml \
     -v release_version=$(cat VERSION) \
     -v gremlin.team_id="$(< platform-team-id)" \
     -v gremlin.team_certificate="$(< platform-team-client.pub_cert.pem)" \
     -v gremlin.team_private_key="$(< platform-team-client.priv_key.pem)" \
     --vars-store creds.yml \
     -o operations/gremlin.yml \
     [other ops-files]
   ```

---

## 📝 Tips & Best Practices

- Keep secrets out of Git. Use `--vars-store creds.yml` or a CredHub ops-file.
- `.gitignore` should exclude build artifacts and local blob caches:

  ```
  blobs/
  .dev_builds/
  .final_builds/
  *.tgz
  config/private.yml
  ```

- Always bump `VERSION` for final releases. CI pipelines can tag and publish automatically.
- Directory permissions for `/var/lib/gremlin` and `/var/log/gremlin` are set to `750` in the `pre-start` hook.

---

## ⚠ Troubleshooting

- Monit looks for the PID at `/var/vcap/sys/run/gremlind/gremlind.pid`—the release’s templates handle this.

