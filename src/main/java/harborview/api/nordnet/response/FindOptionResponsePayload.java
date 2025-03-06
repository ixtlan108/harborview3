package harborview.api.nordnet.response;

public record FindOptionResponsePayload(StockOption option, int status, String msg) {
}
