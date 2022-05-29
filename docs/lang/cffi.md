C Foreign Function Interface (FFI)
=======================

A currently very limited C foreign function interface. 

Types
-----

Types "cint64" and "cbool" represent `int64` from `<cstdint.h>` and `bool` from `<stdbool.h>`.

Program structure changes
-------------------------

Besides the `functions` key, two other optional fields are added:

    {
       "functions": [<Function>, ...],
       "clibraries": [<clibraries>, ...],
       "cfunctions": [<CFunction>, ...]
    }

* `clibraries`: a list of strings.
   The strings are the names of the external libraries to be loaded, useful for the interpreter to load at runtime.
   The library type and location are platform-dependent and interpreter-dependent.
* `cfunctions`: A list of external C functions signatures.

A `CFunction` is defined using the following JSON object, similar to a regular Function:

    {
      "name": "<string>",
      "args": [{"name": "<string>", "type": <CType>}, ...]?,
      "type": <CType>?,
    }

The difference being that types must be the C types specified above.
The "instrs" field is missing.

Operations
----------

Values and variables of types `int` and `bool` must be converted to the corresponding C types before
the call, and from the corresponding C types after the call.

`cffi-convert`: Convert a variable to a C FFI variable and viceversa:

    {
      "op": "cffi-convert",
      "args": ["var1"],
      "dest": "var2",
      "type": <Type>
    }

Either the argument or the dest must be a foreign C type. Moreover the two types must be strictly compatible
according to the following table:

| Bril Type   | C FFI Type  |
| ----------- | ----------- |
| bool        | cbool       |
| int         | cint64      |

Semantics
---------

C functions can be called using a regular `call` operation.

