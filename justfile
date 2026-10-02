build target="debug":
    @cmake --build cmake-build-{{ target }} --target spawn

run target="debug":
    @./cmake-build-{{ target }}/spawn

clean target="debug":
    @rm -rf ./cmake-build-{{ target }}

generate-debug:
    @cmake -S . -B cmake-build-debug -G Ninja

generate-release:
    @cmake -S . -B cmake-build-release -G Ninja -D CMAKE_BUILD_TYPE=Release

install:
    @strip cmake-build-release/spawn
    @cp cmake-build-release/spawn ~/.local/bin
