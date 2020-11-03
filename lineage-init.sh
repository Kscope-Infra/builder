#!/bin/bash

set -euo pipefail

for v in cm-14.1 lineage-15.1 lineage-16.0 lineage-17.1 lineage-18.0; do
    mkdir -p /lineage/$v/.repo/local_manifests
    cd /lineage/$v/
    repo init -u https://github.com/lineageos/android -b $v
done
