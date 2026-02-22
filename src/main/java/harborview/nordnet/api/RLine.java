package harborview.nordnet.api;

import com.fasterxml.jackson.annotation.JsonGetter;

public class RLine {
    private final int oid;
    private final String ticker;
    private final double bid;
    private final double ask;
    private final double riscValue;
    private final double riscStockPrice;
    private final double riscOptionPrice;
    private final double breakEven;

    public RLine(int oid,
                 String ticker,
                 double bid,
                 double ask,
                 double riscValue,
                 double riscStockPrice,
                 double riscOptionPrice,
                 double breakEven) {
        this.oid = oid;
        this.ticker = ticker;
        this.bid = bid;
        this.ask = ask;
        this.riscValue = riscValue;
        this.riscStockPrice = riscStockPrice;
        this.riscOptionPrice = riscOptionPrice;
        this.breakEven = breakEven;
    }

    public int getOid() {
        return oid;
    }

    public String getTicker() {
        return ticker;
    }

    public double getBid() {
        return bid;
    }

    public double getAsk() {
        return ask;
    }

    @JsonGetter("risc")
    public double getRiscValue() {
        return riscValue;
    }

    public double getRiscStockPrice() {
        return riscStockPrice;
    }

    public double getRiscOptionPrice() {
        return riscOptionPrice;
    }

    @JsonGetter("be")
    public double getBreakEven() {
        return breakEven;
    }
}
