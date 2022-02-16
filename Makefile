all: project

PROJECT_NAME=rust_flutter
PROJECT_TARGET=demo
PROJECT=$(PROJECT_TARGET)/$(PROJECT_NAME)

targets:
	@rustup target add \
		x86_64-apple-ios \
		x86_64-apple-darwin \
		aarch64-apple-ios \
		aarch64-apple-darwin \
		aarch64-linux-android \
		armv7-linux-androideabi \
		x86_64-linux-android \
		i686-linux-android

cargo-deps:
	@cargo install cargo-lipo
	@cargo install cargo-ndk
	@cargo install cbindgen
	@cargo install flutter_rust_bridge_codegen

desktop:
	@flutter config --enable-macos-desktop
	@flutter config --enable-linux-desktop
	@flutter config --enable-windows-desktop

project: desktop
	@rm -rf $(PROJECT_TARGET)
	@mkdir -p $(PROJECT_TARGET)
	@cd $(PROJECT_TARGET) && flutter create $(PROJECT_NAME)
	@cd $(PROJECT) && flutter pub get
	@cd $(PROJECT) && cargo new --lib native

.PHONY: project
