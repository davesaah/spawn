package compiler

import e "../errors"
import "core:mem"
import "core:strings"

Parser :: struct {
	lexer:         ^Lexer,
	current_token: Token,
	next_token:    Token,
}

parse_next_token :: proc(p: ^Parser) {
	p.current_token = p.next_token
	p.next_token = get_next_token(p.lexer)
}

new_parser :: proc(l: ^Lexer) -> Parser {
	p := Parser {
		lexer = l,
	}

	parse_next_token(&p) // set next_token first token
	parse_next_token(&p) // set current_token to next_token, then next_token to the actual next
	return p
}

Variable :: struct {
	name:     string,
	value:    string,
	exported: bool,
}

is_number :: proc(c: byte) -> bool {
	return (c >= '0' && c <= '9') || (c == '.')
}

is_variable_assignment :: proc(p: ^Parser) -> bool {
	return p.next_token.type == Symbol.EQUALS
}

// parse_variable_assignment -> IDENTIFIER = IDENTIFIER
parse_variable_assignment :: proc(p: ^Parser) -> (var: Variable, err: e.ErrorResult) {
	var.exported = false
	var.name = p.current_token.literal // current_token is IDENTIFIER

	// variable cannot start with a number

	if is_number(var.name[0]) {
		return {}, e.syntax_error(ctx = p.current_token.literal)
	}

	parse_next_token(p) // current_token is EQUALS
	parse_next_token(p) // current_token is IDENTIFIER
	var.value = p.current_token.literal

	return var, e.no_error()
}

is_variable_export :: proc(p: ^Parser) -> bool {
	return p.current_token.type == Shell.EXPORT
}

// parse_variable_export -> EXPORT IDENTIFIER = IDENTIFIER
parse_variable_export :: proc(p: ^Parser) -> (var: Variable, err: e.ErrorResult) {
	// current_token is EXPORT
	parse_next_token(p) // current_token is IDENTIFIER

	var, err = parse_variable_assignment(p)
	var.exported = true

	return var, err
}

is_variable :: proc(p: ^Parser) -> bool {
	return p.current_token.type == Symbol.DOLLAR && p.next_token.type == Shell.IDENTIFIER
}

// parse_variable -> $IDENTIFIER
parse_variable :: proc(p: ^Parser) -> (var: Variable, err: e.ErrorResult) {
	// current_token is DOLLAR
	parse_next_token(p) // current_token is IDENTIFIER

	var.name = p.current_token.literal
	if is_number(var.name[0]) {
		return {}, e.syntax_error(ctx = p.current_token.literal)
	}

	return var, e.no_error()
}

ShellCmd :: struct {
	command:  string,
	argument: [dynamic]string,
}

shell_args_init :: proc(sh: ^ShellCmd, allocator: mem.Allocator) {
	sh.argument = make([dynamic]string, 0, 4, allocator) // set initital capacity to 4
}

ShellProgram :: union {
	Variable,
	BuiltinCmd,
	ShellCmd,
}

parse_shell_cmd :: proc(
	p: ^Parser,
	allocator: mem.Allocator,
) -> (
	cmd: ShellCmd,
	err: e.ErrorResult,
) {
	cmd.command = strings.clone(p.current_token.literal, allocator)
	shell_args_init(&cmd, allocator)

	// parse_next_token(p) // move to next token

	for p.next_token.type != Symbol.EOF {
		var: Variable

		parse_next_token(p)

		if is_variable(p) {
			var, err = parse_variable(p)
			if err.type != e.ErrorKind.NONE {
				return {}, err
			}

			if err := get_variable(&var, allocator); err.type != e.ErrorKind.NONE {
				return {}, err
			}

			append(&cmd.argument, strings.clone(var.value, cmd.argument.allocator))
			continue
		}

		append(&cmd.argument, strings.clone(p.current_token.literal, cmd.argument.allocator))
	}

	return cmd, e.no_error()
}

parse_shell_input :: proc(
	p: ^Parser,
	allocator: mem.Allocator,
) -> (
	program: ShellProgram,
	err: e.ErrorResult,
) {
	if p.current_token.type != Symbol.EOF {
		if is_variable_assignment(p) {
			return parse_variable_assignment(p)
		}

		if is_variable_export(p) {
			return parse_variable_export(p)
		}

		if is_variable(p) {
			return parse_variable(p)
		}

		if cmd, ok := p.current_token.type.(BuiltinCmd); ok {
			return cmd, e.no_error()
		}

		return parse_shell_cmd(p, allocator)
	}

	return {}, e.no_error()
}
