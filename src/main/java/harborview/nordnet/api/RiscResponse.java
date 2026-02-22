package harborview.nordnet.api;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import harborview.nordnet.stockmarket.StockOptionTicker;

public record RiscResponse(StockOptionTicker ticker,
                           @JsonGetter("stockprice") double stockprice,
                           RiscResponseStatus status) {

    @Override
    @JsonIgnore
    public StockOptionTicker ticker() {
        return ticker;
    }

    @Override
    @JsonIgnore
    public RiscResponseStatus status() {
        return status;
    }

    @JsonGetter("ticker")
    public String getTickerJson() {
        return ticker.value();
    }

    @JsonGetter("status")
    public int statusJson() {
        return status.getStatus();
    }
}
