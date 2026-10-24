package errors

import "core:fmt"
import "core:os"
import "core:sys/posix"

ErrorKind :: enum {
	NONE,
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

get_error_msg :: proc(err: ^ErrorResult) -> string {
	#partial switch t in err.type {
	case posix.Errno:
		return fmt.tprintf("%s\ncontext: %s", posix.strerror(t), err.ctx)
	case os.Error:
		return fmt.tprintf("%s\ncontext: %s", os.error_string(t), err.ctx)
	}
	return fmt.tprintf("%s\ncontext: %s", err.msg, err.ctx)
}
