package compiler

import conf "../configuration"
import e "../errors"
import "core:os"

execute :: proc(program: ^ShellProgram, history_file: ^os.File) -> e.ErrorResult {
	#partial switch v in program {
	case BuiltinCmd:
		switch v {
		case BuiltinCmd.HISTORY:
			conf.display_history(history_file)
		case BuiltinCmd.EXIT:
			os.exit(0)
		}
	}

	return e.no_error()
}
