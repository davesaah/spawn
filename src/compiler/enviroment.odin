package compiler

import e "../errors"
import "core:mem"
import "core:os"
import "core:strings"

// TODO: can check for non exported value when shell_cmd executor is done

set_exported_variable :: proc(v: ^Variable) -> e.ErrorResult {
	if err := os.set_env(v.name, v.value); err != nil {
		return e.ErrorResult{type = err, ctx = "setting exported variable"}
	}
	return e.no_error()
}

lookup_variable :: proc(
	v: ^Variable,
	m: ^map[string]string,
	allocator := context.allocator,
) -> string {
	if value := os.get_env(v.name, allocator); len(value) > 0 {
		return value
	}
	return get_local_variable(v, m)
}

get_variable :: proc(
	v: ^Variable,
	m: ^map[string]string,
	allocator: mem.Allocator,
) -> e.ErrorResult {
	value := lookup_variable(v, m, allocator)
	if len(value) == 0 {
		return e.not_set_error(v.name)
	}

	v.value = value
	return e.no_error()
}

set_local_variable :: proc(v: ^Variable, m: ^map[string]string) {
	map_insert(m, strings.clone(v.name, m.allocator), strings.clone(v.value, m.allocator))
}

get_local_variable :: proc(v: ^Variable, m: ^map[string]string) -> string {
	return m[v.name]
}
