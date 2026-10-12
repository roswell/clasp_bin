FROM ubuntu:20.04
ARG LLVM=18
ARG GCC=13
ARG FMT=9.1.0
ENV DEBIAN_FRONTEND=noninteractive LC_ALL=C.UTF-8 LLVM=$LLVM PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
RUN apt-get update \
 && apt-get install -y curl ca-certificates gnupg git file pkg-config ninja-build sbcl binutils make bzip2 \
 && curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor > /etc/apt/trusted.gpg.d/llvm.gpg \
 && echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-$LLVM main" > /etc/apt/sources.list.d/llvm.list \
 && apt-get update \
 && apt-get install -y clang-$LLVM libclang-$LLVM-dev llvm-$LLVM llvm-$LLVM-dev libpolly-$LLVM-dev \
    libelf-dev libgmp-dev libunwind-dev libboost-all-dev libxml2-dev libicu-dev liblzma-dev zlib1g-dev \
    libzstd-dev libncurses-dev libbsd-dev libffi-dev libedit-dev \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 60C317803A41BA51845E371A1E9377A2BA9EF27F \
 && echo "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu focal main" > /etc/apt/sources.list.d/toolchain.list \
 && apt-get update \
 && apt-get install -y g++-$GCC \
 && rm -rf /var/lib/apt/lists/*
RUN cd /tmp \
 && curl -fsSL https://github.com/fmtlib/fmt/archive/refs/tags/$FMT.tar.gz | tar xz \
 && cd fmt-$FMT \
 && clang++-$LLVM -O2 -fPIC -Iinclude -c src/format.cc src/os.cc \
 && ar rcs /usr/local/lib/libfmt.a format.o os.o \
 && cp -r include/fmt /usr/local/include/ \
 && cd /tmp && rm -rf fmt-$FMT
COPY fmt.pc /usr/local/lib/pkgconfig/fmt.pc
COPY llvm-config-static /usr/local/bin/llvm-config-static
RUN chmod +x /usr/local/bin/llvm-config-static
