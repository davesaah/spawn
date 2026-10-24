package main

import c "configuration"
import "core:fmt"
import "core:mem"

main :: proc() {
	main_stack_buffer: [1024]byte // 1KB
	main_arena: mem.Arena
	mem.arena_init(&main_arena, main_stack_buffer[:])

	sys_info := c.get_info(mem.arena_allocator(&main_arena))
	fmt.println(sys_info.ps1)
}
