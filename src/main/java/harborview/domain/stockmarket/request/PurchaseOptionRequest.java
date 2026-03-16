package harborview.domain.stockmarket.request;

public record PurchaseOptionRequest(String ticker,
                                    int volume) {
    public void validate() {
    }

}
