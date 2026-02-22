package harborview.nordnet.stockmarket;

import harborview.nordnet.util.StockOptionUtil;

import java.util.Objects;

public record StockTicker(String ticker, int oid) {
    public StockTicker(String ticker) {
        this(ticker, StockOptionUtil.mapString(ticker));
    }
    public StockTicker(int oid) {
        this(StockOptionUtil.mapOid(oid), oid);
    }
    public StockTicker(String ticker, int oid) {
        this.ticker = ticker;
        this.oid = oid;
        Objects.requireNonNull(ticker);
    }
}
