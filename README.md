# Docker Davix

This Docker [image] provides [davix]. It is loosely based on the official docker
[image][official] with the following tweaks:

+ There will be no `latest`, instead it will be named after the version of the
  latest [release].
+ This image is based on Ubuntu for faster build times.
+ The image is built in two passes for a minimal footprint.
+ Docker Hub specific [hooks](./hooks) will automatically (re)build whenever a
  new version of [davix] is released or this repository is changed.

  [image]: https://hub.docker.com/r/efrecon/davix
  [davix]: https://github.com/cern-fts/davix
  [official]: https://github.com/cern-fts/davix/tree/devel/docker
  [release]: https://github.com/cern-fts/davix/releases

## Running

Provided the tag `0.7.6` exists, you should be able to call the various `davix`
binaries without their leading `davix-` preamble in the binary name. For
example, to call `davix-ls` inside the Docker image, you could run a command
similar to the following one:

```shell
docker run -it --rm efrecon/davix:0.7.6 ls --help
```

## Building Manually

This image provides a number of build-time arguments that can be changed. Of
main interest is `DAVIX_VERSION`, which can either be the string `latest`, or an
existing version in dotted notation (with or without the leading `v`), e.g.
`0.7.6`. When `latest`, the latest release version at build-time will be
installed, otherwise the version matching the value of the build-time argument,
if it exists.
