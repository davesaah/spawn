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
	main_stack_buffer: [16 * mem.Kilobyte]byte
	main_arena: mem.Arena
	mem.arena_init(&main_arena, main_stack_buffer[:])
	main_alloc := mem.arena_allocator(&main_arena)

	// loop arena: its backing buffer comes from the main arena
	loop_buffer, _ := make([]byte, 8 * mem.Kilobyte, main_alloc)
	loop_arena: mem.Arena
	mem.arena_init(&loop_arena, loop_buffer)
	loop_alloc := mem.arena_allocator(&loop_arena)

	reader: bufio.Reader
	bufio.reader_init(&reader, os.to_stream(os.stdin))
	defer bufio.reader_destroy(&reader)

	sys_info := conf.get_info(main_alloc)

	history_path, p_err := conf.initialize_history(sys_info.homedir, main_alloc)
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

	working_dir, wd_err := os.get_working_directory(main_alloc)
	if wd_err != nil {
		fmt.eprintfln("[unable to access working directory] %s", wd_err)
	}

	process_descriptor := os.Process_Desc {
		working_dir = working_dir,
		stdin       = os.stdin,
		stdout      = os.stdout,
		stderr      = os.stderr,
	}

	for {
		defer free_all(loop_alloc)

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
		shell_program, parse_err := compiler.parse_shell_input(&p, loop_alloc)
		if parse_err.type != e.ErrorKind.NONE {
			fmt.eprintfln("[%s] %s", parse_err.type, e.get_error_msg(&parse_err))
			continue
		}

		if exec_err := compiler.execute(
			&shell_program,
			history_file,
			&process_descriptor,
			sys_info.homedir,
			temp_alloc = loop_alloc,
			main_alloc = main_alloc,
		); exec_err.type != e.ErrorKind.NONE {
			fmt.eprintfln("[execution failed] %s", e.get_error_msg(&exec_err))
		}

		defer {
			fmt.printfln("%v", shell_program)
			fmt.printfln("working dir: %v", process_descriptor.working_dir)
		}
	}
}
