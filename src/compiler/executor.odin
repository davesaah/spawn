package compiler

import conf "../configuration"
import e "../errors"
import "core:fmt"
import "core:mem"
import "core:os"

execute :: proc(
	program: ^ShellProgram,
	history_file: ^os.File,
	allocator: mem.Allocator,
) -> e.ErrorResult {
	switch &v in program {
	case BuiltinCmd:
		switch v {
		case .HISTORY:
			conf.display_history(history_file)
		case .EXIT:
			os.exit(0)
		}
	case Variable:
		if v.exported {
			return set_exported_variable(&v)
		}
	case ShellCmd:
		return run_shell_cmd(&v, allocator)
	}

	return e.no_error()
}

prepare_run_args :: proc(buf: []string, cmd: ^ShellCmd) {
	buf[0] = cmd.command
	copy(buf[1:], cmd.argument[:])
}

run_shell_cmd :: proc(cmd: ^ShellCmd, allocator: mem.Allocator) -> e.ErrorResult {
	command_buf := make([]string, len(cmd.argument) + 1, cmd.argument.allocator)
	prepare_run_args(command_buf, cmd)

	process_descriptor := os.Process_Desc {
		command = command_buf,
		stdin   = os.stdin,
		stdout  = os.stdout,
		stderr  = os.stderr,
	}

	process, ps_err := os.process_start(process_descriptor)
	if ps_err != nil {
		return e.process_error(fmt.aprintf("%v", cmd, allocator = allocator))
	}

	state, w_err := os.process_wait(process)
	if w_err != nil && !state.success {
		return e.process_error(fmt.aprintf("%v", cmd, allocator = allocator))
	}

	return e.no_error()
}
