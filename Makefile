BUILD_DIR := build

DEBUG_DIR := $(BUILD_DIR)/debug
RELEASE_DIR := $(BUILD_DIR)/release

.PHONY: \
	generate-debug \
	generate-release \
	generate \
	build-debug \
	build-release \
	run \
	test \
	benchmark \
	clean

generate-debug:
	@cmake -S . -B $(DEBUG_DIR) \
		-G Ninja \
		-DCMAKE_BUILD_TYPE=Debug \

generate-release:
	@cmake -S . -B $(RELEASE_DIR) \
		-G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTS=OFF \
    -DBUILD_BENCHMARKS=OFF

generate: clean generate-debug generate-release

build-debug: generate-debug
	@cmake --build $(DEBUG_DIR)

build-release: generate-release
	@cmake --build $(RELEASE_DIR)

run: build-debug
	@./$(DEBUG_DIR)/spawn

test: build-debug
	@ctest --test-dir $(DEBUG_DIR) --output-on-failure

benchmark: generate-release
	@cmake --build $(RELEASE_DIR)
	@./$(RELEASE_DIR)/benchmark

clean:
	@rm -rf $(BUILD_DIR)

install: build-release
	@strip $(RELEASE_DIR)/spawn
	@cp $(RELEASE_DIR)/spawn ~/.local/bin
