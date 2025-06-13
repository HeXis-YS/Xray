#!/usr/bin/bash

git submodule update --init --recursive

cp -v $(dirname $0)/lwipopts.h $(dirname $0)/app/src/main/jni/hev-socks5-tunnel/third-part/lwip/src/ports/include/lwipopts.h

ANDROID_API="26"
CROSS_COMPILE="aarch64-linux-android$ANDROID_API-"
CC="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/${CROSS_COMPILE}clang"
LD="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/ld.lld"

XCFLAGS+="-mcpu=cortex-x3+crypto+sha3+nosve -mtune=cortex-a510 "
XCFLAGS+="-Ofast -flto=full -fno-plt -fno-stack-protector "

pushd elfhack/inject
$CC -c -DANDROID -DRELRHACK $XCFLAGS -o aarch64-android.o aarch64-android.c
popd

XLDFLAGS+="-fuse-ld=lld -s -Wl,-O2,--gc-sections "
XLDFLAGS+="-B$(realpath $(dirname $0))/elfhack -Wl,--real-linker,$LD"

export CGO_CFLAGS="$XCFLAGS"
export CGO_CXXFLAGS="$XCFLAGS"
export CGO_LDFLAGS="$XLDFLAGS"
export CGO_ENABLED=0
export GOARM64=v9.0,lse,crypto

export CFLAGS="$XCFLAGS"
export LDFLAGS="$XLDFLAGS"

export JAVA_HOME="$JAVA_HOME_21_X64"

pushd XrayCore
go install golang.org/x/mobile/cmd/gomobile@latest
export PATH="$(realpath ~/go/bin):$PATH"
# go mod tidy
go mod download
gomobile init
gomobile bind -o "../app/libs/XrayCore.aar" -androidapi $ANDROID_API -target "android/arm64" -gcflags=all="-B" -ldflags="-s -w -buildid= -linkmode=external -extld=$CC" -trimpath
popd

./gradlew -PabiId=2 -PabiTarget=arm64-v8a assembleRelease

cp ./app/build/outputs/apk/release/app-arm64-v8a-release-unsigned.apk ./
