package configuration

import e "../errors"
import "core:fmt"
import "core:mem"
import "core:os"


initialize_history :: proc(
	homedir: string,
	allocator: mem.Allocator,
) -> (
	path: string,
	err: e.ErrorResult,
) {
	path = fmt.aprintf("%s/.local/state/spawn", homedir, allocator = allocator)

	if _err := os.make_directory_all(path); _err != nil && !os.is_dir(path) {
		return {}, e.ErrorResult{type = _err, ctx = path}
	}
	return path, e.no_error()
}

append_history :: proc(file: ^os.File, value: string) {
	fmt.fprintln(file, value)
}

display_history :: proc(file: ^os.File) {
	size, _ := os.file_size(file)
	buf := make([]byte, size)
	defer delete(buf)

	n, _ := os.read_at(file, buf, 0)
	fmt.print(string(buf[:n]))
}
