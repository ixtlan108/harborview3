package harborview.nordnet.stockmarket;


import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

public class StockPriceDTO {
    private final StockPrice stockPrice;
    public StockPriceDTO(StockPrice stockPrice) {
        this.stockPrice = stockPrice;
    }

    public double getO() {
        return stockPrice.opn();
    }
    public double getH() {
        return stockPrice.hi();
    }
    public double getL() {
        return stockPrice.lo();
    }
    public double getC() {
        return stockPrice.lo();
    }
    public long getUnixtime() {
        var ld = LocalDate.now();
        var ldt = LocalDateTime.of(ld.getYear(), ld.getMonth(), ld.getDayOfMonth(), 23, 59, 0);
        return ldt.toInstant(ZoneOffset.UTC).toEpochMilli();
        //return Instant.now().getEpochSecond() * 1000;
    }
}
