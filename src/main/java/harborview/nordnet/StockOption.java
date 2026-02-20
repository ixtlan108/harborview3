package harborview.nordnet;

import vega.exception.BinarySearchException;
import vega.financial.StockOptionType;
import vega.financial.calculator.OptionCalculator;

public class StockOption {

    private final StockOptionTicker ticker;
    private final StockOptionType ot;
    private final double x;
    private final double bid;
    private final double ask;
    private final long days;
    private final String expiry;
    private final OptionCalculator calculator;
    private final StockPrice stockPrice;

    private final double DAYS_IN_A_YEAR = 365.0;

    public StockOption(StockOptionTicker ticker,
                       StockOptionType ot,
                       double x,
                       double bid,
                       double ask,
                       long days,
                       String expiry,
                       StockPrice stockPrice,
                       OptionCalculator calculator) {
        this.ticker = ticker;
        this.ot = ot;
        this.x = x;
        this.bid = bid;
        this.ask = ask;
        this.days = days;
        this.expiry = expiry;
        this.stockPrice = stockPrice;
        this.calculator = calculator;
    }

    public StockOptionType getOpType() {
        return ot;
    }

    public double getX() {
        return x;
    }

    public long getDays() {
        return days;
    }

    public StockOptionTicker getTicker() {
        return ticker;
    }

    public double getBid() {
        return bid;
    }

    public double getAsk() {
        return ask;
    }

    public String getExpiry() {
        return expiry;
    }

    private Double ivBid;
    public double getIvBid() {
        if (ivBid == null) {
            ivBid = calculateIv(bid);
        }
        return ivBid;
    }
    private Double ivAsk;
    public double getIvAsk() {
        if (ivAsk == null) {
            ivAsk = calculateIv(ask);
        }
        return ivAsk;
    }
    private Double breakEven;
    public double getBreakEven() {
        if (breakEven == null) {
            breakEven = 12.0; //calculator.breakEven();
        }
        return breakEven;
    }
    private double calculateIv(double price) {
        try {
            return ot == StockOptionType.CALL ?
                    calculator.ivCall(stockPrice.cls(), x, days/DAYS_IN_A_YEAR, price) :
                    calculator.ivPut(stockPrice.cls(), x, days/DAYS_IN_A_YEAR, price);
        }
        catch (BinarySearchException ex) {
            return -1.0;
        }
    }
}
