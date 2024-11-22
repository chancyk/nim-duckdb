# Progress

Uses the DuckDB C API. Currently using the `column_data` API, but this seems
to have been deprecated. The current API might be the `data_chunk` API.

# Issues

- Segfaults when calling `row_count` more than once.
- Only works with basic queries without parameters.

# Run the tests

```
nim c -r tests/tduckdb.nim
```
