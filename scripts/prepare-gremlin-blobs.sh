#!/bin/bash
set -e

# 1) Configure Gremlin APT
sudo apt-get update
sudo apt-get install -y apt-transport-https dirmngr ca-certificates
echo "deb https://deb.gremlin.com/ release non-free" \
  | sudo tee /etc/apt/sources.list.d/gremlin.list
sudo apt-key adv --keyserver keyserver.ubuntu.com \
  --recv-keys 9CDB294B29A5B1E2E00C24C022E8EF3461A50EF6
sudo apt-get update

# 2) Download without installing
mkdir -p tmp && cd tmp
apt-get download gremlin gremlind

# 3a) Extract gremlin + gremlin-gpu
dpkg-deb -x gremlin_*.deb extract1
tar czf gremlin.tar.gz -C extract1/usr/bin gremlin gremlin-gpu

# 3b) Extract gremlind daemon
dpkg-deb -x gremlind_*.deb extract2
tar czf gremlind.tar.gz -C extract2/usr/sbin gremlind

# 4) Move into blobs/
mv gremlin.tar.gz    ../blobs/gremlin/gremlin.tar.gz
mv gremlind.tar.gz   ../blobs/gremlin/gremlind.tar.gz

cd ..
rm -rf tmp
