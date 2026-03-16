package harborview.domain.error;

import harborview.api.response.AppStatusCode;

public sealed interface SqlError extends ApplicationError {
    record DuplicateKeyError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return 2; //AppStatusCode.DUPLICATE_KEY_ERROR;
        }

        @Override
        public String getMsg() {
            return msg;
        }
    }
    record GeneralSqlError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return 3; //AppStatusCode.DUPLICATE_KEY_ERROR;
        }

        @Override
        public String getMsg() {
            return msg;
        }
    }
    record MybatisSqlError(String msg) implements SqlError {
        @Override
        public int getStatus() {
            return 4; //AppStatusCode.DUPLICATE_KEY_ERROR;
        }

        @Override
        public String getMsg() {
            return msg;
        }
    }
}
