#!/bin/bash

set -eu

LIBRARY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY=${LIBRARY:-$(basename $LIBRARY_DIR)}
BUILDPACK_NAME=${BUILDPACK_NAME:-$LIBRARY}
echo "Compiling $LIBRARY"

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
: ${SRC_DIR:?required}
: ${OUTPUT_BLOBS_DIR:?required}
: ${REPO_OUT:?required}
: ${GIT_EMAIL:?required}
: ${GIT_NAME:?required}
REPO_BRANCH=${REPO_BRANCH:-master}

SRC_DIR=$PWD/${SRC_DIR}
OUTPUT_BLOBS_DIR=$PWD/$OUTPUT_BLOBS_DIR

# either set $VERSION, or pass in from ${VERSION_FROM} file (e.g. concourse resource)
VERSION=${VERSION:-}
if [[ ${VERSION_REGEX:-X} != "X" ]]; then
  pushd $SRC_DIR
  f=$(ls $LIBRARY*)
  [[ $f =~ $VERSION_REGEX ]] && { VERSION="${BASH_REMATCH[1]}"; }
  popd
fi
VERSION=${VERSION:-$(cat ${VERSION_FROM})}
echo "VERSION: $VERSION"

S3_BUCKET=${S3_BUCKET:-$LIBRARY-buildpack}
S3_REGION=${S3_REGION:-us-east-2}

TMP_SRC_DIR=${TMP_DIR:-tmp/src}
TMP_SRC_DIR=$PWD/${TMP_SRC_DIR}
TMP_BUILD_DIR=${TMP_DIR:-tmp/build}
TMP_BUILD_DIR=$PWD/${TMP_BUILD_DIR}
mkdir -p $TMP_SRC_DIR
pushd $TMP_SRC_DIR
rm -rf $LIBRARY-*/

SRC_ARCHIVE=$(ls $SRC_DIR/*.tar.gz)
tar xfz $SRC_ARCHIVE
pushd */
./configure --prefix=${TMP_BUILD_DIR} --with-modules --enable-shared
make
make install
popd
popd

mkdir -p $OUTPUT_BLOBS_DIR

pushd $TMP_BUILD_DIR
tar cfz $OUTPUT_BLOBS_DIR/$LIBRARY-compiled-${VERSION}.tgz .
popd

sha=$(sha256sum $OUTPUT_BLOBS_DIR/$LIBRARY-compiled-${VERSION}.tgz | awk '{print $1}')

git clone $ROOT_DIR $REPO_OUT
cat > $REPO_OUT/manifest.yml <<YAML
---
language: $BUILDPACK_NAME
default_versions:
- name: $LIBRARY
  version: $VERSION
dependency_deprecation_dates: []

include_files:
  - README.md
  - VERSION
  - bin/detect
  - bin/supply
  - manifest.yml
pre_package: scripts/build.sh

dependencies:
- name: $LIBRARY
  version: $VERSION
  uri: https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com/blobs/$LIBRARY/$LIBRARY-compiled-$VERSION.tgz
  sha256: ${sha}
  cf_stacks:
  - cflinuxfs3
YAML

# GIT!
if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "${GIT_EMAIL}"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "${GIT_NAME}"
fi

(cd ${REPO_OUT}
 echo "${VERSION}" > VERSION
 git merge --no-edit ${REPO_BRANCH}
 git add -A
 git status
 git commit -m "bump ${LIBRARY} v${VERSION}")