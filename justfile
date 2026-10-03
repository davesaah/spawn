build target="debug":
    @cmake --build cmake-build-{{ target }} --target spawn

run target="debug":
    @./cmake-build-{{ target }}/spawn

clean:
    @rm -rf ./cmake-build-*

generate-debug:
    @cmake -S . -B cmake-build-debug -G Ninja

generate-release:
    @cmake -S . -B cmake-build-release -G Ninja -D CMAKE_BUILD_TYPE=Release \
    -DSPAWN_BUILD_TESTS=OFF \
    -DSPAWN_BUILD_BENCHMARKS=OFF

generate: generate-debug generate-release

# -DCMAKE_EXE_LINKER_FLAGS="-static" \
install:
    @strip cmake-build-release/spawn
    @cp cmake-build-release/spawn ~/.local/bin
