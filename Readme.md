# Compilers and Automata

Coursework in lexical analysis, parsing, and compiler construction. The folders `lab1` through `lab9` preserve successive exercises; **[`lab9`](lab9/)** is the final CMINUS+ compiler project.

## CMINUS+ compiler (`lab9`)

`lab9` is written in C with Lex and YACC. It reads a small C-like program from standard input and emits MIPS assembly to a file. There is no separate intermediate-code or optimization pass in this implementation.

| Stage | Implementation |
| --- | --- |
| Lexing | [`lab9.l`](lab9/lab9.l) recognizes keywords, identifiers, numbers, strings, operators, and comments. |
| Parsing and checks | [`lab9.y`](lab9/lab9.y) defines the grammar, constructs AST nodes, and checks declarations, scopes, types, and function arguments during parsing. |
| Program representation | [`ast.c`](lab9/ast.c) and [`ast.h`](lab9/ast.h) define and display the abstract syntax tree (AST). |
| Symbols and storage | [`symtable.c`](lab9/symtable.c) and [`symtable.h`](lab9/symtable.h) track names, types, scopes, sizes, and offsets. |
| Code generation | [`emit.c`](lab9/emit.c) and [`emit.h`](lab9/emit.h) traverse the AST and write MIPS assembly for variables, expressions, branches, loops, arrays, I/O, and function calls. |

The grammar includes `int` and `void` declarations, functions and parameters, local and global variables, arrays, assignments, arithmetic and comparisons, `if`/`else`, `while`, `read`, `write`, `return`, and function calls. See the source and sample inputs for the exact supported syntax.

## Build and generate assembly

You need a C compiler, Lex-compatible lexer generator, and YACC-compatible parser generator available as `gcc`, `lex`, and `yacc` (for example, GCC, Flex, and Bison with compatible command names).

```bash
git clone https://github.com/mktoon/compilers-and-automata.git
cd compilers-and-automata/lab9
make -B lab9
./lab9 -o sample < test.c
```

The compiler writes `sample.asm`; `-o sample` names the output **without** the `.asm` suffix. Add `-d` to print parser/debug information. Input is redirected from a file because the program calls the parser on standard input; passing `test.c` as a positional argument does not open it.

Sample CMINUS+ inputs include [`test.c`](lab9/test.c) for calls and output and [`testarray.c`](lab9/testarray.c) for loops and nested array indexing. The repository also contains assembly output examples and a MARS JAR for examining MIPS code.

## Current limitations

- This is a course compiler, with no optimization or general C support. The `.c` samples use **CMINUS+ syntax**, not the full C language.
- Use `make -B lab9` to regenerate the lexer, parser, and executable: a compiled `lab9` file is already checked in, and the Makefile's default `all` target does not perform a reliable build.
- Supply `-o` with a basename. The current argument handling does not safely validate a missing output name.
- The code emitter currently writes an un-commented title line before `.data`. Remove or comment that first line in a generated `.asm` file before assembling it in MARS. Other generated instructions have not been verified here for every input.

## Resume description

**CMINUS+ compiler and MIPS code generator** — C, Lex, YACC, MIPS. Built a small-language compiler with lexical analysis, grammar parsing, AST construction, scoped symbol management, semantic checks, and MIPS assembly generation for control flow, arrays, I/O, and function calls.
