package compiler

import "core:strings"
import "core:unicode/utf8"
Lexer :: struct {
	input:            string,
	current_char:     byte,
	current_position: int,
	next_position:    int,
}

new_lexer :: proc(input: string) -> Lexer {
	l := Lexer {
		input = input,
	}

	read_next_char(&l) // set l.current_char to the first one

	return l
}

read_next_char :: proc(l: ^Lexer) {
	if l.next_position >= len(l.input) {
		l.current_char = 0 // ASCII NULL
		l.current_position = len(l.input)
		return
	}

	l.current_char = l.input[l.next_position]
	l.current_position = l.next_position
	l.next_position += 1
}
get_next_token :: proc(l: ^Lexer) -> Token {
	for strings.is_space(rune(l.current_char)) {
		read_next_char(l)
	}

	start := l.current_position
	tok: Token

	switch l.current_char {
	case 0:
		tok.type = Symbol.EOF
		return tok
	case '|':
		tok.type = Symbol.PIPE
	case '=':
		tok.type = Symbol.EQUALS
	case '$':
		tok.type = Shell.ENVIRONMENT
	case:
		for !strings.is_space(rune(l.current_char)) && !is_symbol(l.current_char) {
			read_next_char(l)
		}

		tok.literal = l.input[start:l.current_position]
		tok.type = lookup(tok.literal, start)
		return tok
	}

	tok.literal = l.input[start:l.current_position + 1]
	read_next_char(l)
	return tok
}
