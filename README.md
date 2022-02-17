# Rust Flutter Bindings

A guide to creating a [flutter][] application for all supported platforms on an M1 Mac with bindings to a rust library using [flutter rust bridge][] (FRB).

Before we begin it is important to note that at the time of writing [flutter][] does not have full support for `aarch64` so in some instances 
you will need to ensure you build for `x86_64`.

All platforms will dynamically link the rust code with the exception of iOS which statically links using a universal library.

## Prerequisites

The [rust toolchain][] and [flutter toolchain][] are essential of course.

Your machine should have [xcode][] with the developer tools installed, [android studio][], [parallels][] to build for Windows and Linux as well as the Rosetta `x86_64` emulator.

You should install the [flutter plugin for android studio][].

Best to have a modern version of LLVM available which can be installed using [homebrew][]:

```
brew install llvm
```

## Versions

Lets take a look at the versions of the software we used:

* macOS Monterey 12.1
* Xcode 13.2.1
* Android Studio Bumblebee | 2021.1.1 Patch 1

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

### Cbindgen

```
cbindgen 0.20.0
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

Next up configure flutter for desktop variants:

```
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
```

And install all the targets we need on the host machine:

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

## Codegen

Now we can start to prepare the rust and dart code for codegen, create a new library called `native`:

```
cargo new --lib native
```

Update the `Cargo.toml` to add the required dependencies and set `crate-type` to `cdylib`:

```toml
[package]
name = "rust_flutter"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["staticlib", "cdylib"]
name = "rust_flutter"

[dependencies]
flutter_rust_bridge = "1"
anyhow = "1"
```

And then create a new file `api.rs` with a public function:

```rust
use anyhow::Result;

pub fn simple_adder(a: i32, b: i32) -> Result<i32> {
    Ok(a + b)
}
```

Note that newer versions of FRB support infallible return types but for the moment we need to wrap the return value in a `Result`.

And reference the new module in `lib.rs`:

```
mod api;
```

Now we can generate the code for the bindings:

```
flutter_rust_bridge_codegen --rust-input native/src/api.rs --dart-output lib/bridge_generated.dart -c native/target/bridge_generated.h
```

This will create the file `native/src/bridge_generated.rs` and inject a module import into `lib.rs` so the generated bridge code is compiled.

Also we get the generated dart code in `lib/bridge_generated.dart` and the C header file which we will need later to statically link on iOS.

## MacOS

Getting MacOS compiling and linking the dynamic ibrary is quite straightforward so we will do this one first.

Check that you can run the vanilla flutter app:

```
flutter run -d macos
```

Then open the Xcode project in the `macos` folder and ensure it works via Xcode too (`open macos/Runner.xcodeproj`).

Now build the dynamic library for MacOS `x86_64`:

```
(cd native && cargo build --release --target x86_64-apple-darwin)
```

Now we just need add the dynamic library and bundle the framework.


Right-click the *Frameworks* group and add files, selecting the `../native/target/x86_64-apple-darwin/release/librust_flutter.dylib` file relative to the group.

Then navigate to the *Build Settings* tab and under *Bundle Framework* select the dynamic library we just added to *Frameworks*.

Finally configure the *Library Search Paths* settin in the *Build Settings* tab to include this value:

```
$(SRCROOT)/../native/target/x86_64-apple-darwin/release/
```

Now you should be able to compile and run the project in Xcode and the dynamic library will be bundled and ready to load.

## Initialize the bindings

To load the dynamic library add this code to the top of `lib/main.dart`:

```dart
import 'dart:io';
import 'dart:ffi';
import 'package:rust_flutter/bridge_generated.dart';

const base = 'rust_flutter';
final path = Platform.isWindows
    ? '$base.dll'
    : Platform.isMacOS
        ? 'lib$base.dylib'
        : 'lib$base.so';
late final dylib = Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(path);
late final api = RustFlutterImpl(dylib);
```

## Call the binding

So we can see the result of calling the rust function replace the `_MyHomePageState` class with this code:

```dart
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _add();
  }

  Future<void> _add() async {
    final value = await api.simpleAdder(a: 12, b: 30);
    if (mounted) setState(() => _counter = value);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

Now if you run the application again (`flutter run -d macos` or via xcode) you should see the result of calling the rust function displayed! 

[homebrew]: https://brew.sh/
[rust toolchain]: https://www.rust-lang.org/tools/install
[flutter toolchain]: https://docs.flutter.dev/get-started/install/macos
[flutter rust bridge]: https://github.com/fzyzcjy/flutter_rust_bridge
[flutter]: https://flutter.dev
[parallels]: https://www.parallels.com/
[xcode]: https://developer.apple.com/xcode/
[android studio]: https://developer.android.com/studio/
[flutter plugin for android studio]: https://docs.flutter.dev/development/tools/devtools/android-studio

