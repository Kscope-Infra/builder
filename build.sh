#!/bin/bash

whitelist=(
    alioth
    thyme
)

export IS_OFFICIAL=true

export USE_CCACHE=1
export CCACHE_DIR=${HOME}/.ccache
/usr/bin/ccache -M 30G

if [ -z "${DEVICE}" ]; then
    echo "What's for supper?"
    exit 1
fi

if [ -z "${TYPE}" ]; then
    if [[ "${whitelist[@]}" =~ "${DEVICE}" ]]; then
        export TYPE=userdebug
    else
        export TYPE=user
    fi
fi

cd /buildkite/sunflowerleaf

echo "--- Cleaning"

rm -rf .repo/local_manifests out/target/product
grep -q ${DEVICE} out/last_device
if [ $? -gt 0 ]; then
    rm -rf out/
fi

echo "--- Syncing"

repo init --no-clone-bundle -u https://github.com/Project-Kaleidoscope/android_manifest.git -b sunflowerleaf --depth=1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune || exit 1

echo "--- Launching"

source build/envsetup.sh
lunch kscope_${DEVICE}-${TYPE} || exit 1
echo ${DEVICE} > out/last_device

echo "--- Building"

mka installclean &> /dev/null
mka target-files-package otatools-package | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' || exit 1

echo "--- Finishing"

echo "Done. Build number: ${BUILD_NUMBER}"
