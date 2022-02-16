# Rust Flutter Bindings

A guide to creating a [flutter][] application for all supported platforms on an M1 Mac with bindings to a rust library using [flutter rust bridge][] (FRB).

Before we begin it is important to note that at the time of writing [flutter][] does not have full support for `aarch64` so in some instances 
you will need to ensure you build for `x86_64`.

All platforms will dynamically link the rust code with the exception of iOS which statically links using a universal library.

## Prerequisites

The [rust toolchain][] and [flutter toolchain][] are essential of course.

Your machine should have [xcode][] with the developer tools installed, [android studio][], [parallels][] to build for Windows and Linux as well as the Rosetta `x86_64` emulator.

You should install the [flutter plugin for android][].

Best to have a modern version of LLVM available which can be installed using [homebrew][]:

```
brew install llvm
```

## Versions

Lets take a look at the versions of the software we used:

macOS Monterey 12.1

### Rust

```
rustc 1.58.0 (02072b482 2022-01-11)
```

### LIPO

```
llvm-lipo
Homebrew LLVM version 13.0.1
  Optimized build.
  Default target: arm64-apple-darwin21.2.0
  Host CPU: cyclone
```

### FRB

```
flutter_rust_bridge_codegen 1.16.0
```

### Flutter

This is the beta channel but it should work fine on stable too.

```
Flutter 2.10.0-0.3.pre • channel beta • https://github.com/flutter/flutter.git
Framework • revision fdd0af78bb (3 weeks ago) • 2022-01-25 22:01:33 -0600
Engine • revision 5ac30ef0c7
Tools • Dart 2.16.0 (build 2.16.0-134.5.beta) • DevTools 2.9.2
```

## Getting Started

We will need some additional cargo tools later so lets install them now:

```
cargo install cargo-lipo    # To build the universal libraries for iOS
cargo install cargo-ndk     # To build the JNI libraries for Android
cargo install cbindgen      # Used to generate C headers from the generated rust
```

Also install the main codegen executable which will generate the Dart, Rust and C headers we will need:

```
cargo install flutter_rust_bridge_codegen
```

Ensure that flutter is happy with it's installation:

```
flutter doctor
```

When we build on Windows and Linux we also have to install Flutter in each virtual machine and then it is not so important to ensure that `flutter doctor` is happy but for the primary build machine lets be safe!

Configure flutter for desktop variants:

```
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
```

Install all the targets we need on the host machine:

```
rustup target add \
  x86_64-apple-ios \
  x86_64-apple-darwin \
  aarch64-apple-ios \
  aarch64-apple-darwin \
  aarch64-linux-android \
  armv7-linux-androideabi \
  x86_64-linux-android \
  i686-linux-android
```

[homebrew]: https://brew.sh/
[rust toolchain]: https://www.rust-lang.org/tools/install
[flutter toolchain]: https://docs.flutter.dev/get-started/install/macos
[flutter rust bridge]: https://github.com/fzyzcjy/flutter_rust_bridge
[flutter]: https://flutter.dev
[parallels]: https://www.parallels.com/
[xcode]: https://developer.apple.com/xcode/
[android studio]: https://developer.android.com/studio/
[flutter plugin for android]: https://docs.flutter.dev/development/tools/devtools/android-studio

