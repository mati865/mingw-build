FROM ubuntu:22.04

RUN	apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y build-essential gcc-multilib wget flex texinfo unzip help2man file gawk libtool-bin bison libncurses-dev zstd

WORKDIR /build

RUN wget -q http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.xz 

WORKDIR /build/crosstool-ng

RUN tar xf ../crosstool-ng-*.tar* --strip-components 1

COPY 000*.patch .

RUN for i in *.patch; \
    do patch -p1 -i "$i"; \
    done

# bootstrap because of the new mingw-w64 version
RUN ./bootstrap && ./configure && make install

WORKDIR /build

# Toolchains targeting Windows hosted on Linux
RUN rm -rf crosstool-ng

COPY config.cross64 .config

RUN ct-ng build && rm -rf /build/.build/x86_64-w64-mingw32

COPY config.cross32 .config

RUN ct-ng build && rm -rf /build/.build/i686-w64-mingw32

# Toolchains targeting Windows hosted on Windows 
COPY config.cross-native64 .config

RUN PATH=/root/x-tools/x86_64-w64-mingw32/bin:$PATH ct-ng build && \
    rm -rf /build/.build/HOST-x86_64-w64-mingw32 && \
    mv /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/x86_64-w64-mingw32/sysroot/usr/x86_64-w64-mingw32/bin/*.dll /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/ && \
    mv /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/x86_64-w64-mingw32/sysroot/lib/*.dll /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/ && \
    rm -rf /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/x86_64-w64-mingw32/lib/lib* && \
    cp /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/x86_64-w64-mingw32-gcc.exe /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/gcc.exe && \
    cp /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/x86_64-w64-mingw32-g++.exe /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/g++.exe && \
    cp /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/x86_64-w64-mingw32/debug-root/usr/bin/gdb.exe /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/gdb.exe && \
    cp /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/x86_64-w64-mingw32/debug-root/usr/bin/gdbserver.exe /root/x-tools-cross-native/HOST-x86_64-w64-mingw32/x86_64-w64-mingw32/bin/gdbserver.exe && \
    tar -acf x86_64-w64-mingw32.tar.zst -C /root/x-tools-cross-native/HOST-x86_64-w64-mingw32 x86_64-w64-mingw32

COPY config.cross-native32 .config

RUN PATH=/root/x-tools/i686-w64-mingw32/bin:$PATH ct-ng build && \
    rm -rf /build/.build/HOST-i686-w64-mingw32 && \
    mv /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/i686-w64-mingw32/sysroot/usr/i686-w64-mingw32/bin/*.dll /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/ && \
    mv /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/i686-w64-mingw32/sysroot/lib/*.dll /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/ && \
    rm -rf /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/i686-w64-mingw32/lib/lib* && \
    cp /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/i686-w64-mingw32-gcc.exe /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/gcc.exe && \
    cp /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/i686-w64-mingw32-g++.exe /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/g++.exe && \
    cp /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/i686-w64-mingw32/debug-root/usr/bin/gdb.exe /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/gdb.exe && \
    cp /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/i686-w64-mingw32/debug-root/usr/bin/gdbserver.exe /root/x-tools-cross-native/HOST-i686-w64-mingw32/i686-w64-mingw32/bin/gdbserver.exe && \
    tar -acf i686-w64-mingw32.tar.zst -C /root/x-tools-cross-native/HOST-i686-w64-mingw32 i686-w64-mingw32
