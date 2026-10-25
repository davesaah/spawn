package main

import "compiler"
import conf "configuration"
import "core:bufio"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import e "errors"

main :: proc() {
	main_stack_buffer: [1024]byte // 1KB
	main_arena: mem.Arena
	mem.arena_init(&main_arena, main_stack_buffer[:])

	reader: bufio.Reader
	bufio.reader_init(&reader, os.to_stream(os.stdin))
	defer bufio.reader_destroy(&reader)

	sys_info := conf.get_info(mem.arena_allocator(&main_arena))

	history_path, p_err := conf.initialize_history(
		sys_info.homedir,
		mem.arena_allocator(&main_arena),
	)
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
				conf.append_history(history_file, line)
			}
		}

		l := compiler.new_lexer(line)
		p := compiler.new_parser(&l)
		shell_program, err := compiler.parse_shell_input(&p)
		if err.type != e.ErrorKind.NONE {
			fmt.eprintfln("[%s] %s", err.type, e.get_error_msg(&err))
			continue
		}

		defer {
			fmt.printfln("%v", shell_program)
		}
	}
}
