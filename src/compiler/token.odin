package compiler

import "core:reflect"

BuiltinCmd :: enum {
	EXIT,
	HISTORY,
}

Symbol :: enum {
	PIPE   = '|',
	EQUALS = '=',
	EOF    = 0,
	DOLLAR = '$',
}

Shell :: enum {
	EXPORT,
	IDENTIFIER,
}

TokenType :: union {
	Shell,
	Symbol,
	BuiltinCmd,
}

Token :: struct {
	type:    TokenType,
	literal: string,
}


is_symbol :: proc(b: byte) -> bool {
	return reflect.enum_value_has_name(Symbol(b))
}

lookup :: proc(s: string, p: int) -> TokenType {
	switch s {
	case "exit":
		return BuiltinCmd.EXIT
	case "history":
		return BuiltinCmd.HISTORY
	case "export":
		return Shell.EXPORT
	case:
		return Shell.IDENTIFIER
	}
}
