package harborview.domain.error;

import harborview.api.response.AppStatusCode;

public sealed interface GeneralError extends ApplicationError {
    int GENERAL_ERROR = 10;
    record GeneralApplicationError(String msg) implements GeneralError {
        @Override
        public int getStatus() {
            return GENERAL_ERROR;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
    record Warning(String msg) implements GeneralError {
        @Override
        public int getStatus() {
            return GENERAL_ERROR + 1;
        }
        @Override
        public String getMsg() {
            return msg;
        }
    }
}
