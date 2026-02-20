package harborview.nordnet;


import java.util.List;

public interface NordnetRepository {
    List<StockOption> getCalls(StockTicker ticker);
    List<StockOption> getPuts(StockTicker ticker);
    StockPrice getStockPrice(StockTicker ticker);
    Tuple2<StockPrice,StockOption> findOption(StockOptionTicker ticker);
    //OpeningPrice openingPrice(StockTicker ticker);
    void resetCaffeine();
}
