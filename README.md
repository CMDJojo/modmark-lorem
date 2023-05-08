# Lorem - a ModMark package

This repo contains code for a [ModMark](https://github.com/modmark-org/modmark) package with a module called `[lorem]`. It is mostly a proof-of-concept that it does work to create a module in Swift.

## Build instructions

Install [SwiftWasm](https://swiftwasm.org) on your platform and use SwiftPM to build the product in this folder.

On macOS, `xcrun --toolchain swiftwasm swift build --triple wasm32-unknown-wasi -c release` may work. It might be a good idea to run `wasm-opt` to reduce the binary size.

## Testing

You can test this by supplying `example.json` to `stdin`, like `cat example.json | swift run lorem transform lorem html`. 
