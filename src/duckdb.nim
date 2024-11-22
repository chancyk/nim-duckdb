{.passL: "-L./vendored -lduckdb".}
{.pragma: duckdb, cdecl, dynlib: "duckdb", header: "duckdb.h".}

type
  idx_t* = uint64
  DuckDBType* = enum
    Invalid = 0,
    Boolean = 1,
    Tinyint = 2,
    Smallint = 3,
    Integer = 4,
    BigInt = 5,
    UTinyInt = 6,
    USmallInt = 7,
    UInteger = 8,
    UBigInt = 9,
    Float = 10,
    Double = 11,
    Timestamp = 12,
    Date = 13,
    Time = 14,
    Interval = 15,
    HugeInt = 16,
    UHugeInt = 32,
    Varchar = 17,
    Blob = 18,
    Decimal = 19,
    TimestampS = 20,
    TimestampMs = 21,
    TimestampNs = 22,
    Enum = 23,
    List = 24,
    Struct = 25,
    Map = 26,
    Array = 33,
    UUID = 27,
    Union = 28,
    Bit = 29,
    TimeTz = 30,
    TimestampTz = 31,
    Any = 34,
    VarInt = 35,
    SQLNull = 36

  DuckDBErrorType* = enum
    ErrorInvalid = 0,
    ErrorOutOfRange = 1,
    ErrorConversion = 2,
    ErrorUnknownType = 3,
    ErrorDecimal = 4,
    ErrorMismatchType = 5,
    ErrorDivideByZero = 6,
    ErrorObjectSize = 7,
    ErrorInvalidType = 8,
    ErrorSerialization = 9,
    ErrorTransaction = 10,
    ErrorNotImplemented = 11,
    ErrorExpression = 12,
    ErrorCatalog = 13,
    ErrorParser = 14,
    ErrorPlanner = 15,
    ErrorScheduler = 16,
    ErrorExecutor = 17,
    ErrorConstraint = 18,
    ErrorIndex = 19,
    ErrorStat = 20,
    ErrorConnection = 21,
    ErrorSyntax = 22,
    ErrorSettings = 23,
    ErrorBinder = 24,
    ErrorNetwork = 25,
    ErrorOptimizer = 26,
    ErrorNullPointer = 27,
    ErrorIO = 28,
    ErrorInterrupt = 29,
    ErrorFatal = 30,
    ErrorInternal = 31,
    ErrorInvalidInput = 32,
    ErrorOutOfMemory = 33,
    ErrorPermission = 34,
    ErrorParameterNotResolved = 35,
    ErrorParameterNotAllowed = 36,
    ErrorDependency = 37,
    ErrorHTTP = 38,
    ErrorMissingExtension = 39,
    ErrorAutoload = 40,
    ErrorSequence = 41,
    ErrorConfiguration = 42

  DuckDBState* = enum
    DuckDBSuccess = 0,
    DuckDBError = 1

  DuckDBDatabaseObj* = object
    internal_ptr: pointer
  DuckDBDatabase* = ptr DuckDBDatabaseObj

  DuckDBConnectionObj* = object
    internal_ptr: pointer
  DuckDBConnection* = ptr DuckDBConnectionObj

  DuckDBResultObj* = object
    deprecated_column_count: idx_t
    deprecated_row_count: idx_t
    deprecated_rows_changed: idx_t
    deprecated_columns: pointer
    deprecated_error_message: cstring
    internal_data: pointer
  DuckDBResult* = ptr DuckDBResultObj

  DuckDBPreparedStatementObj* = object
    internal_ptr: pointer
  DuckDBPreparedStatement* = ptr DuckDBPreparedStatementObj

  FloatColumn* = seq[float]


proc open*(path: cstring, out_database: ptr DuckDBDatabase): DuckDBState {.duckdb, importc: "duckdb_open".}
proc close*(database: ptr DuckDBDatabase) {.duckdb, importc: "duckdb_close".}
proc connect*(database: DuckDBDatabase, out_connection: ptr DuckDBConnection): DuckDBState {.duckdb, importc: "duckdb_connect".}
proc disconnect*(connection: ptr DuckDBConnection) {.duckdb, importc: "duckdb_disconnect".}

proc prepare*(connection: DuckDBConnection, query: cstring, out_prepared_statement: ptr DuckDBPreparedStatement): DuckDBState {.duckdb, importc: "duckdb_prepare".}
proc execute_prepared*(prepared_statement: DuckDBPreparedStatement, out_result: ptr DuckDBResult): DuckDBState {.duckdb, importc: "duckdb_execute_prepared".}
proc result_error*(result: ptr DuckDBResult): cstring {.duckdb, importc: "duckdb_result_error".}
proc result_error_type*(result: ptr DuckDBResult): DuckDBErrorType {.duckdb, importc: "duckdb_result_error_type".}

proc column_name*(result: ptr DuckDBResult, col: idx_t): cstring {.duckdb, importc: "duckdb_column_name".}
proc column_type*(result: ptr DuckDBResult, col: idx_t): DuckDBType {.duckdb, importc: "duckdb_column_type".}
proc column_count*(result: ptr DuckDBResult): idx_t {.duckdb, importc: "duckdb_column_count".}
proc row_count*(result: ptr DuckDBResult): idx_t {.duckdb, importc: "duckdb_row_count".}
proc column_data*(result: ptr DuckDBResult, col: idx_t): pointer {.duckdb, importc: "duckdb_column_data".}
proc destroy_result*(result: ptr DuckDBResult) {.duckdb, importc: "duckdb_destroy_result".}

iterator iter_column*[T](query_result: DuckDBResult, col: idx_t): T =
  let num_rows = row_count(addr query_result)
  let col_ptr = column_data(addr query_result, col)
  let column = cast[ptr UncheckedArray[T]](col_ptr)
  var i: idx_t = 0
  while i < num_rows:
    yield column[i]
    i += 1
