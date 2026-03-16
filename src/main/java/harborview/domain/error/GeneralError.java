package harborview.domain.error;

import harborview.api.response.AppStatusCode;

public sealed interface GeneralError extends ApplicationError {
    record GeneralApplicationError(String msg) implements GeneralError {
        @Override
        public int getStatus() {
            return 1; //AppStatusCode.GENERAL_SQL_ERROR;
        }

        @Override
        public String getMsg() {
            return msg;
        }
    }
}
