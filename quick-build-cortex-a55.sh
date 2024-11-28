#!/bin/bash

git submodule update --init --recursive

XCFLAGS="-Wno-unused-command-line-argument -mcpu=cortex-a55+crypto+ssbs -mtune=cortex-a55 -O3 -ffast-math -flto=full -fno-stack-protector -mllvm=-enable-ext-tsp-block-placement=1 -mllvm=-polly -mllvm=-polly-vectorizer=stripmine -mllvm=-polly-loopfusion-greedy=1 -mllvm=-polly-run-inliner -mllvm=-polly-run-dce -mllvm=-polly-2nd-level-tiling -mllvm=-polly-position=before-vectorizer -mllvm=-polly-invariant-load-hoisting -fuse-ld=lld -s -Wl,-O2,--as-needed,--gc-sections,--icf=all,-z,lazy,-z,norelro,--enable-new-dtags"
export CGO_CFLAGS="$XCFLAGS"
export CGO_CXXFLAGS="$XCFLAGS"
export CGO_LDFLAGS="$XCFLAGS"
export CGO_ENABLED=0
export GOEXPERIMENT=newinliner
export GOARM64=v8.2,lse,crypto

export CFLAGS="$XCFLAGS"
export LDFLAGS="$XCFLAGS"

pushd XrayCore
go install golang.org/x/mobile/cmd/gomobile@latest
export PATH=$(realpath ~/go/bin):$PATH
# go mod tidy
go mod download
gomobile init
gomobile bind -o "../app/libs/XrayCore.aar" -androidapi 26 -target "android/arm64" -gcflags=all="-B" -ldflags="-s -w -buildid=" -trimpath 
popd

./gradlew -PabiId=2 -PabiTarget=arm64-v8a assembleRelease

cp ./app/build/outputs/apk/release/app-arm64-v8a-release-unsigned.apk ./
