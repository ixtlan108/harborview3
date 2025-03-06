package harborview.api.response;

public record PayloadResponse<T>(T payload, AppStatusCode appStatusCode, String error) {
}
