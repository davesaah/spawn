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
	temp_alloc: mem.Allocator,
	main_alloc: mem.Allocator,
) -> e.ErrorResult {
	switch &v in program {
	case Variable:
		if v.exported {
			return set_exported_variable(&v)
		}
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

	if !os.is_directory(cmd.argument[0]) {
		return e.process_error(
			msg = "directory does not exist",
			ctx = fmt.aprintf("%v", cmd, allocator = temp_alloc),
		)
	}

	pd.working_dir = strings.clone(cmd.argument[0], main_alloc)
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
	command_buf := make([]string, len(cmd.argument) + 1, cmd.argument.allocator)
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
