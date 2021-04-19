---
title: Python PEG Grammar
category: technology
---

The Python programming language has its own PEG parser since 3.10, which was derived from its EBNF notation in former versions. Here are some significant characteristics of its PEG parser:

1. Python PEG Parser is only used internally. The parser has no public C API.
2. The input grammar[0] needs to be compiled to file `parser.c`[1] first.
3. Python PEG grammar allows left-recursion. So `sum = sum '+' term | sum '-' term | term` is allowed and won’t end up with stack exhausted.
4. Python PEG grammar don’t have CST to AST conversion. The grammar rules are compiled from source code to AST directly given an "action" block followed by the definitions. The action blocks are in essence raw C code that will be copied into `parser.c`[1] in verbatim.
   For example, if there is an exact keyword match for `pass`, an AST node for pass will be created.
   ```
   simple_stmt:
     ... (truncated)
     | 'pass' { _PyAST_Pass(EXTRA) }
     ... (truncated)
   ```
5. Python provides ASDL description to aid the AST generation. ASDL file (Python.asdl[2]) is parsed to a "meta-AST" by asdl_c.py, then emit C statements into a "Include/internal/pycore_ast.h"[3] file and "Python/Python-ast.c"[4]. The functions in "Python/Python-ast.c"[4] happens to be those action code in PEG grammar.

[0]: https://github.com/python/cpython/blob/master/Grammar/python.gram
[1]: https://github.com/python/cpython/blob/master/Parser/parser.c
[2]: https://github.com/python/cpython/blob/master/Parser/Python.asdl
[3]: https://github.com/python/cpython/blob/master/Include/internal/pycore_ast.h
[4]: https://github.com/python/cpython/blob/master/Python/Python-ast.c
