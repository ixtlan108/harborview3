package harborview.nordnet.repository;


import harborview.nordnet.*;
import harborview.nordnet.stockmarket.StockOption;
import harborview.nordnet.stockmarket.StockOptionTicker;
import harborview.nordnet.stockmarket.StockPrice;
import harborview.nordnet.stockmarket.StockTicker;

import java.util.List;

public interface NordnetRepository {
    List<StockOption> getCalls(StockTicker ticker);
    List<StockOption> getPuts(StockTicker ticker);
    StockPrice getStockPrice(StockTicker ticker);
    Tuple2<StockPrice,StockOption> findOption(StockOptionTicker ticker);
    //OpeningPrice openingPrice(StockTicker ticker);
    void resetCaffeine();
}
