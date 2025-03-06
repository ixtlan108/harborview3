package harborview.domain.stockmarket;

import java.time.LocalDate;
import java.util.List;
import java.util.function.Consumer;

public interface StockMarketRepository {
    List<Stock> getStocks();
    Stock findStock(int oid);
    List<StockPrice> getStockPrices(StockTicker ticker, LocalDate fromDx);
    List<StockOptionPurchase> activePurchasesWithCritters(int purchaseType);
    void toggleRule(int ruleId, boolean active, boolean isAccRule);
    StockOption findStockOption(StockOptionTicker stockOptionTicker);
    void insertPurchase(StockOptionPurchase purchase, Consumer<Exception> errorHandler);
    void insertSale(StockOptionSale sale, Consumer<Exception> errorHandler);
    void insertStockOption(StockOption option, Consumer<Exception> errorHandler);

    List<StockOptionPurchase> stockOptionPurchases(int purchaseType, int status, String opType);

    StockPrice getSpot(StockTicker ticker);
}
