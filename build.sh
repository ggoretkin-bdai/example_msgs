#!/usr/bin/env bash

# enable emulating aarch64 
#docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
#docker stop earthly-buildkitd || true

mkdir -p build

# some options for building this package

# make a `.deb` for aarch64 by doing native compilation on top of QEMU
#earthly --platform=linux/arm64 -i +build-bloom-container-native

# make a `.deb` for x64 by doing native compilation
#earthly -i +build-bloom-container-native

# What about running compilation natively but targeting another platform (true cross compilation)?
# ????

# For reference, this is how to build the package, without bloom, natively.
earthly -i +build-colcon
