package compiler

import "core:reflect"

Keyword :: enum {
	EXIT,
	EXPORT,
	HISTORY,
}

Symbol :: enum {
	PIPE   = '|',
	EQUALS = '=',
	EOF    = 0,
}

Shell :: enum {
	COMMAND,
	IDENTIFIER,
	ENVIRONMENT,
}

TokenType :: union {
	Shell,
	Symbol,
	Keyword,
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
		return Keyword.EXIT
	case "history":
		return Keyword.HISTORY
	case "export":
		return Keyword.EXPORT
	}

	if (p == 0) {
		return Shell.COMMAND
	}

	return Shell.IDENTIFIER
}
