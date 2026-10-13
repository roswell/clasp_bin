#!/bin/sh
set -ex
VERSION=${VERSION:-3.0.1}
JOBS=${JOBS:-2}
VERSION_SUFFIX=${VERSION_SUFFIX-.roswell}
ARCH=`uname -m | sed -e s/aarch64/arm64/ -e s/x86_64/x86-64/`
NAME=clasp-$VERSION-$ARCH-linux
OUT=`pwd`
STATIC="-lxml2 -licuuc -licudata -llzma -lz -lzstd -ledit -lbsd -ltinfo -lffi -lfmt -lgmpxx -lgmp -lelf"
mkdir -p /b && cd /b
if [ -n "$REF" ]; then
  git clone https://github.com/clasp-developers/clasp clasp-$VERSION
  cd clasp-$VERSION
  git checkout $REF
  SYNC=
else
  curl -fsSL https://github.com/clasp-developers/clasp/releases/download/$VERSION/clasp-$VERSION.tar.gz | tar xz
  cd clasp-$VERSION
  SYNC=--skip-sync
fi
./koga $SYNC --version=$VERSION$VERSION_SUFFIX --nm=nm --jobs=$JOBS --static-linking --no-clang-cpp \
  --llvm-config=/usr/local/bin/llvm-config-static --build-path=build/ \
  --bin-path=/opt/clasp/bin/ --lib-path=/opt/clasp/lib/clasp/ \
  --share-path=/opt/clasp/share/clasp/ --dylib-path=/opt/clasp/lib/ \
  --ldflags="-L/usr/local/lib -static-libstdc++"
cp build/build.ninja build/build.ninja.orig
awk '/^ldlibs = /{f=1} f{ if (sub(/ *\$$/,"")) {printf "%s ", $0; next} else {print; f=0; next} } {print}' build/build.ninja.orig \
  | sed -E "/^ldlibs = /{s/  +/ /g; s/ -lfmt -lgmpxx -lgmp -lelf//; s/\$/ -Wl,--start-group -Wl,-Bstatic $STATIC -Wl,-Bdynamic -Wl,--end-group/}" > build/build.ninja
ninja -C build -j $JOBS
ninja -C build install
D=/b/$NAME
rm -rf $D
mkdir -p $D/build/boehmprecise/generated
cp -a /opt/clasp/share/clasp/. $D/
find $D -maxdepth 1 -type f -exec mv {} $D/build/boehmprecise/generated/ \;
cp -a /opt/clasp/bin/iclasp $D/build/boehmprecise/
strip --strip-debug $D/build/boehmprecise/iclasp
cp -a /opt/clasp/lib/clasp $D/build/boehmprecise/lib
rm -f $D/build/boehmprecise/lib/*.a
ldd $D/build/boehmprecise/iclasp > $D/build/boehmprecise/ldd.txt
cd /b
tar czf $OUT/$NAME-binary.tar.gz $NAME
ls -l $OUT/$NAME-binary.tar.gz
cat $D/build/boehmprecise/ldd.txt
