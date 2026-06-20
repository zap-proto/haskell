This directory contains data for use with the test suite:

* `aircraft.zap` is a schema with many useful datatypes
* `schema-codegenreq` is the output of
   `zap compile /usr/include/zap/schema.zap -o-`. It would be nice
   to keep this in textual form and convert it with zap encode, so it
   could be viewed more easily, but unfortunately it contains
   `AnyPointer`s, so `zap decode` -> `zap encode` fails.
