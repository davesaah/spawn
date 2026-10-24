package main

import c "configuration"
import "core:bufio"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import e "errors"

main :: proc() {
	main_stack_buffer: [2048]byte // 1KB
	main_arena: mem.Arena
	mem.arena_init(&main_arena, main_stack_buffer[:])

	reader: bufio.Reader
	bufio.reader_init(&reader, os.to_stream(os.stdin))
	defer bufio.reader_destroy(&reader)

	sys_info := c.get_info(mem.arena_allocator(&main_arena))

	history_path, p_err := c.initialize_history(sys_info.homedir, mem.arena_allocator(&main_arena))
	if p_err.type != e.ErrorKind.NONE {
		fmt.eprintfln("[unable to initialize history] %s", e.get_error_msg(&p_err))
		os.exit(1)
	}

	history_file, h_err := os.open(
		fmt.tprintf("%s/history", history_path),
		os.File_Flags{.Create, .Append, .Write, .Read},
		os.Permissions_Read_All + os.Permissions{.Write_User},
	)

	if h_err != nil {
		fmt.eprintfln("[unable to access history file] %s", h_err)
	}
	defer os.close(history_file)

	for {
		fmt.print(sys_info.ps1)
		bytes, _ := bufio.reader_read_slice(&reader, '\n')
		line := strings.trim_space(string(bytes))
		defer {
			if len(line) != 0 {
				c.append_history(history_file, line)
			}
		}

		switch line {
		case "exit":
			os.exit(0)
		case "history":
			c.display_history(history_file)
			continue
		}
	}
}
