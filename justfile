build:
    @mkdir -p build/debug
    @odin build src -debug -out:build/debug/spawn

clean:
    @rm -rf build

run: build
    @./build/debug/spawn

release:
    @mkdir -p build/bin
    @odin build src -out:build/bin/spawn
