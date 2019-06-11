# ImageMagick 7 buildpack for Cloud Foundry

## Why use this buildpack

Cloud Foundry base stack `cflinuxfs3` includes legacy ImageMagick v6+, whereas modern ImageMagick is v7+.

Without this buildpack you will see ImageMagick 6.9.7 or so:

```plain
$ cf ssh myapp
# /tmp/lifecycle/shell
# convert -version
Version: ImageMagick 6.9.7-4 Q16 x86_64 20170114 http://www.imagemagick.org
```

With this buildpack you will see ImageMagick 7.0.8 or higher:

```plain
$ cf ssh phpapp
# /tmp/lifecycle/shell
# convert -version
Version: ImageMagick 7.0.8-49 Q16 x86_64 2019-06-10 https://imagemagick.org
Copyright: © 1999-2019 ImageMagick Studio LLC
License: https://imagemagick.org/script/license.php
Features: Cipher DPC HDRI OpenMP(4.5)
Delegates (built-in): bzlib djvu fontconfig freetype jbig jng jpeg lcms lqr lzma openexr png tiff wmf x xml zlib
```

## Why not use this buildpack

Some language bindings do not yet support ImageMagick v7, such as:

* Ruby [`rmagick`](https://github.com/rmagick/rmagick) - [estimated support for ImageMagick7 Summer 2019](https://github.com/rmagick/rmagick/issues/256)
* Ruby [`minimagick`](https://github.com/minimagick/minimagick) - accidentally discovers legacy ImageMagick6; [waiting on PR](https://github.com/minimagick/minimagick/pull/478)

## Updates via CI

A new version of this buildpack will be automatically published for each new ImageMagick release from our [CI pipeline](https://ci2.starkandwayne.com/teams/cfcommunity/pipelines/imagemagick-buildpack).

## Buildpack User Documentation

### Building the Buildpack

To build this buildpack, run the following command from the buildpack's directory:

1. Source the .envrc file in the buildpack directory.

    ```bash
    source .envrc
    ```

    To simplify the process in the future, install [direnv](https://direnv.net/) which will automatically source .envrc when you change directories.

1. Install buildpack-packager

    ```bash
    ./scripts/install_tools.sh
    ```

1. Build the buildpack

    ```bash
    buildpack-packager build -stack cflinuxfs3 -cached
    ```

1. Use in Cloud Foundry

    Upload the buildpack to your Cloud Foundry and optionally specify it by name

    ```bash
    cf create-buildpack imagemagick_buildpack imagemagick_buildpack*.zip 100
    cf push phpapp -b imagemagick_buildpack -b php_buildpack -p fixtures/phpapp
    ```

### Testing

Buildpacks use the [Cutlass](https://github.com/cloudfoundry/libbuildpack/cutlass) framework for running integration tests.

To test this buildpack, run the following command from the buildpack's directory:

1. Source the .envrc file in the buildpack directory.

    ```bash
    source .envrc
    ```

    To simplify the process in the future, install [direnv](https://direnv.net/) which will automatically source .envrc when you change directories.

1. Run integration tests

    ```bash
    ./scripts/integration.sh
    ```

    To run integration tests against CFDev:

    ```bash
    cf login -a https://api.dev.cfdev.sh --skip-ssl-validation -u admin -p admin
    CUTLASS_SCHEMA=https CUTLASS_SKIP_TLS_VERIFY=true ./scripts/integration.sh
    ```

    More information can be found on Github [cutlass](https://github.com/cloudfoundry/libbuildpack/cutlass).

### Reporting Issues

Open an issue on this project

## Disclaimer

This buildpack is experimental and not yet intended for production use.
