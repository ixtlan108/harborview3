package harborview.api.response;

import com.fasterxml.jackson.annotation.JsonValue;

public enum AppStatusCode {
    OK(1),
    GENERAL_ERROR(2),
    DUPLICATE_KEY_ERROR(3),
    GENERAL_SQL_ERROR(4),
    MYBATIS_SQL_ERROR(5);

    private final int statusCode;

    AppStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    @JsonValue
    public int getStatusCode() {
        return statusCode;
    }
}
