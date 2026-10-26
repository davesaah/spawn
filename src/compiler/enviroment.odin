package compiler

import e "../errors"
import "core:mem"
import "core:os"

// TODO: can check for non exported value when shell_cmd executor is done

set_exported_variable :: proc(v: ^Variable) -> e.ErrorResult {
	if err := os.set_env(v.name, v.value); err != nil {
		return e.ErrorResult{type = err, ctx = "setting exported variable"}
	}
	return e.no_error()
}

get_variable :: proc(v: ^Variable, allocator: mem.Allocator) -> e.ErrorResult {
	// TODO: extract env from path variable
	// e.g. $HOME/Downloads -> /userhome/Downloads
	value := os.get_env(v.name, allocator)
	if len(value) == 0 {
		return e.not_set_error(v.name)
	}

	v.value = value
	return e.no_error()
}
