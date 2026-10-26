# Technical Documentation

## Memory Decisions

- Keep all memory allocations on the stack.
- Avoid all use of global variables.
- Allocations for entire project is set to 32 KB.
- Allocations for loop context is set to 8 KB.
- Loop allocations are from main allocation context and freed independently. This means, the 8 KB is from the 32 KB, not separate from it.
