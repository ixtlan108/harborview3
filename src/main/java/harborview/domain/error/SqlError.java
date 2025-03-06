package harborview.domain.error;

public sealed interface SqlError extends ApplicationError {
    record DuplicateKeyError(String msg) implements SqlError {}
    record GeneralSqlError(String msg) implements SqlError {}
    record MybatisSqlError(String msg) implements SqlError {}
}
