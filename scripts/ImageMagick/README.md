# Build imagemagick within cflinuxfs3

Our buildpack users will need to download a pre-compiled version of [imagemagick](https://www.imagemagick.org/). This Dockerfile describes how to compile imagemagick and output it as a `tgz` file. Another part of the toolchain will upload the tgz to a public place, from which buildpack users will download it on demand.

```plain
VERSION=7.0.8-49
mkdir -p tmp/imagemagick-src
curl -L -o tmp/imagemagick-src/imagemagick-$VERSION.tar.gz https://github.com/ImageMagick/ImageMagick/archive/$VERSION.tar.gz

rm -rf tmp/imagemagick-output
mkdir -p tmp/imagemagick-output
docker run -ti \
  -v $PWD:/buildpack \
  -v $PWD/tmp/imagemagick-src:/imagemagick-src \
  -v $PWD/tmp/imagemagick-output:/imagemagick-output \
  -e "VERSION_REGEX=ImageMagick-(.*).tar.gz" \
  -e SRC_DIR=/imagemagick-src \
  -e OUTPUT_BLOBS_DIR=/imagemagick-output/blobs \
  -e REPO_OUT=/imagemagick-output/pushme \
  -e "GIT_NAME=$(git config user.name)" \
  -e "GIT_EMAIL=$(git config user.email)" \
  -e "S3_BUCKET=imagemagick-buildpack" \
  -e "S3_REGION=us-east-2" \
  cloudfoundry/cflinuxfs3 \
  /buildpack/scripts/ImageMagick/compile.sh
```

Then upload new compiled blobs to your S3 account/bucket. In CI, this is performed with an `s3` resource.

```plain
bucket=imagemagick-buildpack
aws s3 cp --recursive tmp/imagemagick-output/blobs s3://$bucket/blobs/imagemagick
```

The updated `manifest.yml` is already committed into a cloned repo within `tmp/imagemagick-output/pushme`.

```plain
cat tmp/imagemagick-output/pushme/manifest.yml
---
language: ImageMagick
default_versions:
- name: ImageMagick
  version: 7.0.8-49
dependency_deprecation_dates: []

include_files:
  - README.md
  - VERSION
  - bin/supply
  - manifest.yml
pre_package: scripts/build.sh

dependencies:
- name: ImageMagick
  version: 7.0.8-49
  uri: https://imagemagick-buildpack.s3.us-east-2.amazonaws.com/blobs/ImageMagick/ImageMagick-compiled-7.0.8-49.tgz
  sha256: 0ee2bb83eefa717142d56b38b85ca5815bcf8fdef1ad1b078331a65c629c5588
  cf_stacks:
  - cflinuxfs3
```
