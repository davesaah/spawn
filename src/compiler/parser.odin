package compiler

import e "../errors"
import "core:mem"
import "core:strings"
import "core:unicode"

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

is_valid_varchar :: proc(c: rune) -> bool {
	return unicode.is_alpha(c) || c == '_' || unicode.is_digit(c)
}

is_valid_var_name :: proc(t: Token) -> bool {
	if t.type != Shell.IDENTIFIER {
		return false
	}

	if len(t.literal) == 0 {
		return false
	}

	if unicode.is_digit(rune(t.literal[0])) {
		return false
	}

	bad_index := strings.index_proc(t.literal, is_valid_varchar, false)
	return bad_index == -1

}

is_variable_assignment :: proc(p: ^Parser) -> bool {
	return p.next_token.type == Symbol.EQUALS
}

// parse_variable_assignment -> IDENTIFIER = IDENTIFIER
parse_variable_assignment :: proc(p: ^Parser) -> (var: Variable, err: e.ErrorResult) {
	if !is_valid_var_name(p.current_token) {
		return {}, e.syntax_error(ctx = p.current_token.literal)
	}

	var.exported = false
	var.name = p.current_token.literal // current_token is IDENTIFIER

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

	if !is_valid_var_name(p.current_token) {
		return {}, e.syntax_error(ctx = p.current_token.literal)
	}
	var.name = p.current_token.literal

	return var, e.no_error()
}

Command :: union {
	string,
	BuiltinCmd,
}

ShellCmd :: struct {
	command:  Command,
	argument: [dynamic]string,
}

shell_args_init :: proc(sh: ^ShellCmd, allocator: mem.Allocator) {
	sh.argument = make([dynamic]string, 0, 4, allocator) // set initital capacity to 4
}

ShellProgram :: union {
	Variable,
	ShellCmd,
}

parse_shell_cmd :: proc(
	p: ^Parser,
	allocator: mem.Allocator,
) -> (
	cmd: ShellCmd,
	err: e.ErrorResult,
) {
	if command, ok := p.current_token.type.(BuiltinCmd); ok {
		cmd.command = command
	} else {
		cmd.command = strings.clone(p.current_token.literal, allocator)
	}

	shell_args_init(&cmd, allocator)

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

		return parse_shell_cmd(p, allocator)
	}

	return {}, e.no_error()
}
