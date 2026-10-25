package compiler

import conf "../configuration"
import e "../errors"
import "core:os"

execute :: proc(program: ^ShellProgram, history_file: ^os.File) -> e.ErrorResult {
	#partial switch &v in program {
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
	}

	return e.no_error()
}
