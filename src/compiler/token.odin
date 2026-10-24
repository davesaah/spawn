package compiler

Keyword :: enum {
	EXIT,
	EXPORT,
	HISTORY,
}

Symbol :: enum {
	PIPE,
	EQUALS,
}

Shell :: enum {
	COMMAND,
	ARGUMENT,
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

	return Shell.ARGUMENT
}
