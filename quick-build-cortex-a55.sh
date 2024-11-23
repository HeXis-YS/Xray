#!/bin/bash

git submodule update --init --recursive

XCFLAGS="-Wno-unused-command-line-argument -mcpu=cortex-a55+crypto+ssbs -mtune=cortex-a55 -Ofast -flto=full -fno-common -fno-plt -fno-semantic-interposition -fno-stack-protector -fcf-protection=none -mllvm=-enable-ext-tsp-block-placement=1 -mllvm=-polly -mllvm=-polly-vectorizer=stripmine -mllvm=-polly-ast-use-context -mllvm=-polly-loopfusion-greedy -mllvm=-polly-run-inliner -mllvm=-polly-run-dce -fuse-ld=lld -s -Wl,-O2,--gc-sections,--icf=all,-z,lazy,-z,norelro,-sort-common"
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
