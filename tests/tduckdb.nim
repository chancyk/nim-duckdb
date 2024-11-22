import duckdb, macros


block:
  var
    db: DuckDBDatabase
    conn: DuckDBConnection
    query_result: DuckDBResult
    prepared_statement: DuckDBPreparedStatement
    values = newSeq[float32]()

  let open_result = open("./tests/test.db", addr db)
  echo "OPENED: ", open_result
  let conn_result = connect(db, addr conn)
  echo "CONNECTED: ", conn_result
  let prepare_result = prepare(conn, "SELECT max(float_col) FROM float_table", addr prepared_statement)
  echo "PREPARED: ", prepare_result
  let execute_result = execute_prepared(prepared_statement, addr query_result)
  echo "EXECUTED: ", execute_result
  if execute_result == DuckDBSuccess:
    let col_name = column_name(addr query_result, 0)
    let col_type = column_type(addr query_result, 0)
    echo "COLUMN: ", col_name, ": ", col_type
    for value in iter_column[float32](query_result, 0):
      values.add(value)

    assert values.len == 1
    assert values[0] == 10.0

  disconnect(addr conn)
  close(addr db)
  echo "PASSED"
