package harborview.domain.error;

import harborview.api.response.AppStatusCode;
import org.apache.ibatis.jdbc.SQL;

public sealed interface SqlError extends ApplicationError {
    int SQL_ERROR = 20;
    record GeneralSqlError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return SQL_ERROR;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
    record DuplicateKeyError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return SQL_ERROR + 1;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
    record MybatisError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return SQL_ERROR + 2;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
    record PostgresError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return SQL_ERROR + 3;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
    record BadGrammarError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return SQL_ERROR + 4;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
    record Warning(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return SQL_ERROR + 5;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
}
