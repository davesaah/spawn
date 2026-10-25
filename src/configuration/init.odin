package configuration

import "core:fmt"
import "core:mem"
import "core:strings"
import "core:sys/posix"

Info :: struct {
	ps1:     string,
	homedir: string,
}

get_info :: proc(allocator: mem.Allocator) -> Info {
	HOSTNAME_MAX_BYTES :: 256
	info: Info
	username := "user"
	hostname := "pc"

	// Username & HOME directory
	if pw := posix.getpwuid(posix.getuid()); pw != nil {
		username = string(pw.pw_name)
		info.homedir = strings.clone_from_cstring(pw.pw_dir, allocator)
	}

	// Hostname
	buf: [HOSTNAME_MAX_BYTES]byte
	// the last byte untouched since the buffer is always null-terminated.
	if posix.gethostname(raw_data(buf[:]), len(buf) - 1) == .OK {
		hostname = string(cstring(raw_data(buf[:])))
	}

	info.ps1 = fmt.aprintf("%s@%s$ ", username, hostname, allocator = allocator)
	return info
}
