#!/bin/bash
set -euo pipefail

/usr/local/bin/fixuid 2>&1

export HOME="/buildkite"

export KBUILD_BUILD_USER=buildbot
export KBUILD_BUILD_HOST=kscope-build

git config --global color.ui false
git config --global user.name "KaleidoscopeOS Buildbot"
git config --global user.email "nobody@localhost"

DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]] ; then
  echo "Executing scripts in $DIR"
  /bin/run-parts --exit-on-error "$DIR"
fi

exec /sbin/tini -g -- /usr/local/bin/buildkite-agent "$@"
