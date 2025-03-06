package harborview.api.nordnet.response;

public record FindOptionResponse(FindOptionResponsePayload payload, int appStatusCode, String error) {
}
