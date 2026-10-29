# Technical Documentation

## Memory Decisions

- Keep all memory allocations on the stack.
- Avoid all use of global variables.
- Allocations for entire project is set to 32 KB.
- Allocations for loop context is set to 8 KB.
- Loop allocations are from main allocation context and freed independently. This means, the 8 KB is from the 32 KB, not separate from it.

## Processing User Input

- Handles single line and multi-line **(planned)** input.

### Stages of Processing User Input

- By default, user input is retrieved from a buffered reader that is streamed from standard input.
- All whitespaces around the `string` are removed.
- The new value is used as input for spawn's lexer.
- The lexer is used as input for spawn's parser, which in turn returns a shell program.

## Error Design

The project deals with 3 kinds of errors:

1. OS errors.
2. POSIX errors.
3. Custom errors (ErrorKind enum).

## How Tokens Are Parsed

### Lexical Anaylsis

Converts user input into a stream of token. Defined tokens include:

- Shell: EXPORT, IDENTIFIER.
- Symbol: PIPE, EQUALS, EOF, DOLLAR.
- BuiltinCmd: EXIT, HISTORY, CD.

### Semantic Analysis

Follows the grammar of spawn to recognise shell programs.

eBNF:

```ebnf
program             = variable_assignment
                    | variable_export
                    | shell_cmd ;

variable_assignment = variable_name , "=" , value ;

variable_export     = "export" , ws , variable_assignment ;

shell_cmd           = command , { ws , argument } ;

command             = built_in_cmd | word ;

built_in_cmd        = "exit" | "cd" | "history" ;

argument            = word ;

value               = { word_char } ;

(* Variable names: start with a letter, then letters, digits, underscores *)
variable_name       = letter , { letter | digit | "_" } ;

(* Strings *)
word                = word_char , { word_char } ;
word_char           = letter | digit | symbol ;

letter              = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I"
                    | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R"
                    | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z"
                    | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i"
                    | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r"
                    | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;

ws                  = " " , { " " } ;

digit               = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

symbol              = "!" | "@" | "#" | "$" | "%" | "^" | "&" | "*" | "("
                    | ")" | "-" | "_" | "+" | "=" | "[" | "]" | "{" | "}"
                    | "\" | "|" | ";" | ":" | "'" | "," | "." | "<"
                    | ">" | "/" | "?" | "`" | "~" ;
```

## How Shell Programs are Executed

A shell program in spawn can either be:

1. A variable: variable assignment and export.
2. A shell command: built-in commands and everything else.

### Variables

There are two kinds of variables spawn supports:

1. Exported variables: the values persists to child process.
2. Local variables **(planned)**: the values are local to the current process.

### Shell Commands

A shell command is either built-in or available in path. Built-in commands are entirely handled by spawn while system commands are not. Rather, it's processes are managed.

Available built-in commands (more will be added):

- `cd` to change working directory.
- `history` to view command history.
- `exit` to exit spawn.

## Keybinds (Planned)

Certain operations can be handled via keybinds. Example:

- Cancel user input entry.
- Gracefully exit spawn.
- Cycle through command history.

It is available to allow many other keybinds.

## I/O Redirections (Planned)

## Interprocess Communication (Planned)
