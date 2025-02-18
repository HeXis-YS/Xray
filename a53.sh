#!/bin/bash

git submodule update --init --recursive

cp -v $(dirname $0)/lwipopts.h $(dirname $0)/app/src/main/jni/hev-socks5-tunnel/third-part/lwip/src/ports/include/lwipopts.h

ANDROID_API="26"

XFLAGS="-Wno-unused-command-line-argument "
XFLAGS+="-mcpu=cortex-a53 -mtune=cortex-a53 "
XFLAGS+="-O3 -ffast-math -flto=full -fno-stack-protector -mllvm=-enable-ext-tsp-block-placement=1 "
XFLAGS+="-mllvm=-polly -mllvm=-polly-vectorizer=stripmine -mllvm=-polly-loopfusion-greedy=1 -mllvm=-polly-run-inliner -mllvm=-polly-run-dce -mllvm=-polly-2nd-level-tiling -mllvm=-polly-position=before-vectorizer -mllvm=-polly-invariant-load-hoisting "

XFLAGS+="-fuse-ld=lld -s -Wl,-O2,--as-needed,--gc-sections,--icf=all,-z,lazy,-z,norelro,--enable-new-dtags "

export CGO_CFLAGS="$XFLAGS"
export CGO_CXXFLAGS="$XFLAGS"
export CGO_LDFLAGS="$XFLAGS"
export CGO_ENABLED=0
# export GOEXPERIMENT=newinliner
export GOARM=7

export CFLAGS="$XFLAGS"
export LDFLAGS="$XFLAGS"

export JAVA_HOME="$JAVA_HOME_21_X64"

pushd XrayCore/libXray
go install golang.org/x/mobile/cmd/gomobile@latest
export PATH="$(realpath ~/go/bin):$PATH"
# go mod tidy
go mod download
gomobile init
gomobile bind -o "../../app/libs/XrayCore.aar" -androidapi $ANDROID_API -target "android/arm" -gcflags=all="-B" -ldflags="-s -w -buildid=" -trimpath
popd

./gradlew -PabiId=1 -PabiTarget=armeabi-v7a assembleRelease

cp ./app/build/outputs/apk/release/app-armeabi-v7a-release-unsigned.apk ./
