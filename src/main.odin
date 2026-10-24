package main

import c "configuration"
import "core:bufio"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"

main :: proc() {
	main_stack_buffer: [1024]byte // 1KB
	main_arena: mem.Arena
	mem.arena_init(&main_arena, main_stack_buffer[:])

	reader: bufio.Reader
	bufio.reader_init(&reader, os.to_stream(os.stdin))
	defer bufio.reader_destroy(&reader)

	sys_info := c.get_info(mem.arena_allocator(&main_arena))

	for {
		fmt.print(sys_info.ps1)
		bytes, _ := bufio.reader_read_slice(&reader, '\n')
		line := strings.trim_space(string(bytes))

		if line == "exit" {
			break
		}
	}
}
