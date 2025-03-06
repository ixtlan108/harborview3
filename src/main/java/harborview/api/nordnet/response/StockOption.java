package harborview.api.nordnet.response;

public record StockOption(String ticker,
                          double bid,
                          double ask,
                          double ivBid,
                          double ivAsk,
                          double x,
                          int days,
                          double close,
                          String optionType) {
}
