package harborview.adapter.stockmarket;

import harborview.adapter.RedisAdapter;
import harborview.domain.stockmarket.StockMarketRepository;
import harborview.domain.stockmarket.*;
import harborview.mybatis.CritterMapper;
import harborview.mybatis.MyBatisUtil;
import harborview.mybatis.StockMapper;
import harborview.mybatis.StockOptionMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.function.Consumer;

@Component()
@Profile({"prod","hilo","atest","integration"})
public class StockMarketAdapter implements StockMarketRepository {

    private final Logger logger = LoggerFactory.getLogger(StockMarketAdapter.class);

    private final MyBatisUtil myBatisUtil;
    private final Date fromDate;
    private final RedisAdapter redisAdapter;

    private List<Stock> stocks;

    public StockMarketAdapter(MyBatisUtil myBatisUtil,
                              RedisAdapter redisAdapter,
                              @Value("${adapter.stockmarket.from-date}") String fromDate) {
        this.myBatisUtil = myBatisUtil;
        this.redisAdapter = redisAdapter;
        this.fromDate =  java.sql.Date.valueOf(fromDate);
        logger.info(String.format("From date: %s", this.fromDate.toString()));
    }

    private void populateStocksIfEmtpy() {
        if (stocks == null) {
            myBatisUtil.withSessionConsumer(session -> {
                var mapper = session.getMapper(StockMapper.class);
                stocks = mapper.selectStocks();
            });
        }
    }

    @Override
    public List<Stock> getStocks() {
        populateStocksIfEmtpy();
        return stocks;
    }

    @Override
    public Stock findStock(int oid) {
        populateStocksIfEmtpy();
        for (var s : stocks) {
            if (s.getOid() == oid) {
                return s;
            }
        }
        return null;
    }

    @Override
    public List<StockPrice> getStockPrices(StockTicker ticker, LocalDate fromDx) {
        return (myBatisUtil.withSession(session -> {
            var mapper = session.getMapper(StockMapper.class);
            if (fromDx == null) {
                return mapper.selectStockPrices(ticker.oid(), fromDate);
            }
            else {
                return mapper.selectStockPrices(ticker.oid(), Date.valueOf(fromDx));
            }
        }));
    }

    @Override
    public List<StockOptionPurchase> activePurchasesWithCritters(int purchaseType) {
        return (myBatisUtil.withSession(session -> {
            var mapper = session.getMapper(CritterMapper.class);
            return mapper.activePurchasesWithCritters(purchaseType);
        }));
    }

    @Override
    public void toggleRule(int ruleId, boolean active, boolean isAccRule) {
       myBatisUtil.withSessionConsumer(session -> {
           var mapper = session.getMapper(CritterMapper.class);
           var isActive = active ? "y" : "n";
           if (isAccRule) {
               mapper.toggleAcceptRule(ruleId, isActive);
           }
           else {
               mapper.toggleDenyRule(ruleId, isActive);
           }
       });
    }

    @Override
    public StockOption findStockOption(StockOptionTicker stockOptionTicker) {
        return (myBatisUtil.withSession(session -> {
                                            var mapper = session.getMapper(StockOptionMapper.class);
                                            return mapper.findStockOption(stockOptionTicker.ticker());
                                            }));
    }

    @Override
    public void insertPurchase(StockOptionPurchase purchase, Consumer<Exception> errorHandler) {
        myBatisUtil.withSessionConsumer(session -> {
                var mapper = session.getMapper(StockOptionMapper.class);
                mapper.insertPurchase(purchase);
            }, errorHandler);
    }

    @Override
    public void insertSale(StockOptionSale sale, Consumer<Exception> errorHandler) {
        myBatisUtil.withSessionConsumer(session -> {
            var mapper = session.getMapper(StockOptionMapper.class);
            mapper.insertSale(sale);
        }, errorHandler);
    }

    @Override
    public void insertStockOption(StockOption option, Consumer<Exception> errorHandler) {
        myBatisUtil.withSessionConsumer(session -> {
                var mapper = session.getMapper(StockOptionMapper.class);
                mapper.insertStockOption(option);
            }, errorHandler);
    }

    @Override
    public List<StockOptionPurchase> stockOptionPurchases(int purchaseType, int status, String opType) {
        return (myBatisUtil.withSession(session -> {
            var mapper = session.getMapper(StockOptionMapper.class);
            return mapper.purchasesWithSalesAll(purchaseType, status, opType);
        }));
    }

    @Override
    public StockPrice getSpot(StockTicker ticker) {
        return redisAdapter.getSpot(ticker);
    }
}
