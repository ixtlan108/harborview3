package harborview.domain.stockmarket;

import java.time.LocalDate;
import java.util.List;
import java.util.function.Consumer;

public interface StockMarketService {
    List<Stock> getStocks();
    Stock findStock(int oid);
    List<StockPrice> getStockPrices(StockTicker ticker, LocalDate fromDx);
    List<StockOptionPurchase> activePurchasesWithCritters(int purchaseType);
    void toggleRule(int ruleId, boolean active, boolean isAccRule);
    StockOption findStockOption(StockOptionTicker stockOptionTicker);
    void insertPurchase(StockOptionPurchase purchase);
    void insertSale(StockOptionSale sale);
    void insertStockOption(StockOption option);

    List<StockOptionPurchase> stockOptionPurchases(int purchaseType, int status, String opType);

    StockPrice getSpot(StockTicker ticker);
}
