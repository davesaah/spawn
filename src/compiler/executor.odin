package compiler

import conf "../configuration"
import e "../errors"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"

execute :: proc(
	program: ^ShellProgram,
	history_file: ^os.File,
	process_descriptor: ^os.Process_Desc,
	homedir: string,
	variables: ^map[string]string,
	temp_alloc: mem.Allocator,
	main_alloc: mem.Allocator,
) -> e.ErrorResult {
	switch &v in program {
	case Variable:
		if v.exported {
			return set_exported_variable(&v)
		} else {
			set_local_variable(&v, variables)
		}

	case Pipeline:
		return run_pipeline(&v, process_descriptor, temp_alloc)
	case ShellCmd:
		switch t in v.command {
		case string:
			return run_shell_cmd(&v, process_descriptor, temp_alloc)
		case BuiltinCmd:
			switch t {
			case .HISTORY:
				conf.display_history(history_file)
			case .EXIT:
				os.exit(0)
			case .CD:
				return run_cd(&v, process_descriptor, homedir, temp_alloc, main_alloc)
			}
		}
	}

	return e.no_error()
}

run_pipeline :: proc(
	pipeline: ^Pipeline,
	pd: ^os.Process_Desc,
	temp_alloc: mem.Allocator,
) -> e.ErrorResult {
	if len(pipeline.cmds) == 0 {
		return e.no_error()
	}

	processes := make([dynamic]os.Process, temp_alloc)
	prev_read: ^os.File

	for &cmd, idx in pipeline.cmds {
		is_last := idx == len(pipeline.cmds) - 1 // check if last command

		next_read, next_write: ^os.File

		if !is_last {
			err: os.Error
			next_read, next_write, err = os.pipe()
			if err != nil {
				return e.ErrorResult {
					type = err,
					ctx = fmt.aprintf("%v", pipeline, allocator = temp_alloc),
				}
			}
		}

		command_buf := make([]string, len(cmd.argument) + 1, temp_alloc)
		prepare_run_args(command_buf, &cmd)

		process, p_err := os.process_start(
			{
				command = command_buf,
				working_dir = pd.working_dir,
				stdin = prev_read if prev_read != nil else os.stdin,
				stdout = next_write if next_write != nil else os.stdout,
				stderr = os.stderr,
				env = pd.env,
			},
		)

		// Parent needs to close what the child now owns
		if prev_read != nil {os.close(prev_read)}
		if next_write != nil {os.close(next_write)}

		if p_err != nil {
			if next_read != nil {os.close(next_read)}
			return e.ErrorResult{type = p_err, ctx = fmt.aprintf("%v", pd, allocator = temp_alloc)}
		}

		append(&processes, process)
		prev_read = next_read
	}

	for p, idx in processes {
		// wait for processes to finish
		state, w_err := os.process_wait(p)
		if w_err != nil {
			return e.ErrorResult{type = w_err, ctx = fmt.aprintf("%v", p, allocator = temp_alloc)}
		}
		_ = os.process_kill(p)
	}

	return e.no_error()
}

run_cd :: proc(
	cmd: ^ShellCmd,
	pd: ^os.Process_Desc,
	homedir: string,
	temp_alloc: mem.Allocator,
	main_alloc: mem.Allocator,
) -> e.ErrorResult {
	if len(cmd.argument) > 1 {
		return e.process_error(
			msg = "cannot have more than 2 arguments",
			ctx = fmt.aprintf("%v", cmd, allocator = temp_alloc),
		)
	}

	if len(cmd.argument) == 0 {
		pd.working_dir = homedir
		return e.no_error()
	}

	argv := cmd.argument[0]
	if !strings.has_prefix(argv, "/") {
		argv = fmt.aprintf("%s/%s", pd.working_dir, argv, allocator = temp_alloc)
	}

	if !os.is_directory(argv) {
		return e.process_error(
			msg = "directory does not exist",
			ctx = fmt.aprintf("%v", cmd, allocator = temp_alloc),
		)
	}

	pd.working_dir = strings.clone(argv, main_alloc)
	return e.no_error()
}

prepare_run_args :: proc(buf: []string, cmd: ^ShellCmd) {
	buf[0] = cmd.command.(string)
	copy(buf[1:], cmd.argument[:])
}

run_shell_cmd :: proc(
	cmd: ^ShellCmd,
	pd: ^os.Process_Desc,
	temp_alloc: mem.Allocator,
) -> e.ErrorResult {
	command_buf := make([]string, len(cmd.argument) + 1, temp_alloc)
	prepare_run_args(command_buf, cmd)

	pd.command = command_buf

	process, ps_err := os.process_start(pd^)
	if ps_err != nil {
		return e.cmd_not_found(fmt.aprintf("%v", cmd, allocator = temp_alloc))
	}

	state, w_err := os.process_wait(process)
	if w_err != nil && !state.success {
		return e.ErrorResult{type = w_err, ctx = fmt.aprintf("%v", cmd, allocator = temp_alloc)}
	}

	return e.no_error()
}
