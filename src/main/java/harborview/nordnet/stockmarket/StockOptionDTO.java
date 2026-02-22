package harborview.nordnet.stockmarket;


public class StockOptionDTO {
    private final StockOption stockOption;
    public StockOptionDTO(StockOption stockOption) {
        this.stockOption = stockOption;
    }

    public String getTicker() {
        return stockOption.getTicker().value();
    }
    public double getX() {
        return stockOption.getX();
    }
    public double getBid() {
        return stockOption.getBid();
    }
    public double getAsk() {
        return stockOption.getAsk();
    }
    public long getDays() {
        return stockOption.getDays();
    }
    public double getIvBid() {
        return stockOption.getIvBid();
    }
    public double getIvAsk() {
        return stockOption.getIvAsk();
    }
    public double getBrEven() {
        return stockOption.getBreakEven();
    }
    public String getExpiry() {
        return stockOption.getExpiry();
    }
}
