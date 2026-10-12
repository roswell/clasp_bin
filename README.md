# clasp_bin

Prebuilt [clasp](https://github.com/clasp-developers/clasp) for Roswell.

Built on Ubuntu 20.04 (glibc 2.31) with LLVM 18. Everything but glibc and
libgcc_s is linked statically, so the archive runs on any glibc >= 2.31
distribution without extra packages, from any directory.

## Build

```
docker build -t clasp-build tools-for-build/glibc2.31
docker run --rm -v $PWD:/w -w /w -e VERSION=3.0.1 clasp-build sh /w/build.sh
docker run --rm -v $PWD:/w:ro ubuntu:20.04 sh /w/test.sh /w/clasp-3.0.1-`uname -m | sed -e s/aarch64/arm64/ -e s/x86_64/x86-64/`-linux-binary.tar.gz
```
