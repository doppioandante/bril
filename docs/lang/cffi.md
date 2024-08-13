C Foreign Function Interface (FFI)
=======================

A limited C foreign function interface. 

Program structure changes
-------------------------

Besides the `functions` key, one other optional field `cffi` is added:

    {
       "functions": [<Function>, ...],
       "clibraries": [<CLibrary>, ...],
    }

* `clibraries`: a list C libraries to call functions from.

A `CLibrary` is defined as:

    {
        "abspath": "<string>",
        "functions": [<CFunction>, ...],
    }
* `abspath`: the absolute path of the library. The library format is implementation dependent.
* `functions`: A list of external C functions signatures.

A `CFunction` is defined by the following JSON object, similar to a regular Function:

    {
      "name": "<string>",
      "args": [<Type>, ...],
      "return-type": <Type>?,
    }

`return-type` is optional, its absence denotes a void function.

Operations
----------

`ccall`: Call a C function

    {
      "op": "ccall",
      "args": [clib, cfunction, "<string>"...?],
      "dest": "<string>",
      "type": <Type>,
      "funcs": ...,
      "labels": ...,
    }

* `clib`: the index of the library where the C function resides into the `clibraries` list.
* `cfunction`: string with the name of the C function to be called:w
* `args`: list of arguments to be given to the function (possibily empty)

A C function with no return value (void) shall be an effect instr, with no `dest` and `type` fields.

Only C functions that have a signature with compatible bril types can be called.
The compatibility is depicted in the following table:

| Bril Type   | C type      |
| ----------- | ----------- |
| bool        | bool        |
| int         | int64       |

Semantics
---------

The result of calling a C Function with side effects is generally undefined.

