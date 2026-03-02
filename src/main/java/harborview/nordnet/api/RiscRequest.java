package harborview.nordnet.api;

import com.fasterxml.jackson.annotation.JsonSetter;
import harborview.nordnet.stockmarket.StockOptionTicker;

public class RiscRequest {
    private StockOptionTicker ticker;
    private double riscValue;

    public RiscRequest(StockOptionTicker ticker,
                       double riscValue) {
        this.ticker = ticker;
        this.riscValue = riscValue;
    }

    public RiscRequest() {
    }

    public StockOptionTicker getTicker() {
        return ticker;
    }

    @JsonSetter("ticker")
    public void setTicker(String value) {
        ticker = new StockOptionTicker(value);
    }

    public double getRiscValue() {
        return riscValue;
    }

    @JsonSetter("risc")
    public void setRiscValue(double value) {
        riscValue = value;
    }

}
