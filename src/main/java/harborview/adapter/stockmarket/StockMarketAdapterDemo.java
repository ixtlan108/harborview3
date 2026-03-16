package harborview.adapter.stockmarket;

import harborview.adapter.RedisAdapter;
import harborview.domain.stockmarket.*;
import harborview.mybatis.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.function.Consumer;

@Component()
@Profile({"demo","cmdline","test"})
public class StockMarketAdapterDemo extends StockMarketAdapter {

    public StockMarketAdapterDemo(SqlSession sqlSession,
                                  MyBatisUtil myBatisUtil,
                                  RedisAdapter redisAdapter,
                                  @Value("${adapter.stockmarket.from-date}") String fromDate) {
        super(sqlSession, myBatisUtil, redisAdapter, fromDate);
    }
    /*
    @Override
    public List<Stock> getStocks() {
        return null;
    }

    @Override
    public List<StockPrice> getStockPrices(StockTicker ticker, LocalDate fromDx) {
        return null;
    }

    @Override
    public List<StockOptionPurchase> activePurchasesWithCritters(int purchaseType) {
        return null;
    }

    @Override
    public void toggleRule(int ruleId, boolean active, boolean isAccRule) {

    }

    @Override
    public StockOption findStockOption(StockOptionTicker stockOptionTicker) {
        return null;
    }

     */

    @Override
    public Stock findStock(int oid) {
        var result = new Stock();
        result.setOid(3);
        result.setTicker("YAR");
        return result;
    }

    @Override
    public void insertPurchase(StockOptionPurchase purchase) {

    }
}
