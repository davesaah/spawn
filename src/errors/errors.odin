package errors

import "core:fmt"
import "core:os"
import "core:sys/posix"

ErrorKind :: enum {
	NONE,
	SYNTAX_ERROR,
	NOT_SET_ERROR,
}

ErrorType :: union {
	ErrorKind,
	posix.Errno,
	os.Error,
}

ErrorResult :: struct {
	type: ErrorType,
	msg:  string,
	ctx:  string,
}

no_error :: proc() -> ErrorResult {
	return ErrorResult{type = ErrorKind.NONE}
}

syntax_error :: proc(ctx: string) -> ErrorResult {
	return ErrorResult {
		type = ErrorKind.SYNTAX_ERROR,
		msg = "variable cannot start with a number",
		ctx = ctx,
	}
}

not_set_error :: proc(ctx: string) -> ErrorResult {
	return ErrorResult {
		type = ErrorKind.NOT_SET_ERROR,
		msg = "no value has been set for environment variable",
		ctx = ctx,
	}
}

get_error_msg :: proc(err: ^ErrorResult) -> string {
	#partial switch t in err.type {
	case posix.Errno:
		return fmt.tprintf("%s\ncontext: %s", posix.strerror(t), err.ctx)
	case os.Error:
		return fmt.tprintf("%s\ncontext: %s", os.error_string(t), err.ctx)
	}
	return fmt.tprintf("%s\ncontext: %s", err.msg, err.ctx)
}
