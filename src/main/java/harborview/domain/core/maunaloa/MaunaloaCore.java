package harborview.domain.core.maunaloa;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import harborview.domain.core.Core;
import harborview.domain.error.ApplicationError;
import harborview.domain.functional.Either;
import harborview.domain.stockmarket.StockMarketService;
import harborview.chart.ChartFactory;
import harborview.chart.ChartMonthFactory;
import harborview.chart.ChartWeekFactory;
import harborview.domain.stockmarket.StockOptionPurchase;
import harborview.domain.stockmarket.StockOptionSale;
import harborview.domain.stockmarket.StockOptionTicker;
import harborview.domain.stockmarket.StockPrice;
import harborview.domain.stockmarket.StockTicker;
import harborview.dto.StatusDTO;
import harborview.dto.html.Charts;
import harborview.dto.html.SelectItem;
import harborview.nordnet.api.RLine;
import harborview.nordnet.api.RiscRequest;
import harborview.nordnet.api.RiscResponse;
import harborview.nordnet.api.RiscResponseStatus;
import harborview.nordnet.repository.NordnetRepository;
import harborview.nordnet.util.StockOptionUtil;
import oahu.dto.Tuple2;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import vega.exception.BinarySearchException;
import vega.financial.calculator.OptionCalculator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Consumer;
import java.util.stream.Collectors;

import harborview.dto.StatusCode;

@Component
public class MaunaloaCore {

    private Logger logger = LoggerFactory.getLogger(MaunaloaCore.class);
    private final StockMarketService stockMarketAdapter;
    private final ChartFactory chartFactory = new ChartFactory();
    private final ChartWeekFactory chartWeekFactory = new ChartWeekFactory();
    private final ChartMonthFactory chartMonthFactory = new ChartMonthFactory();
    Cache<Integer, List<StockPrice>> stockPriceCache = Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .build();

    private List<SelectItem> stockTickers;

    private final Core core;

    public MaunaloaCore(StockMarketService stockMarketAdapter,
                        Core core) {
        this.stockMarketAdapter = stockMarketAdapter;
        this.core = core;
    }

    //@Cacheable(value="stockTickers")
    public Either<ApplicationError,List<SelectItem>> getStockTickers() {
        return core.handleSearch(() -> {
            if (stockTickers == null) {
                logger.info("(getStockTickers) Empty cache");
                stockTickers = stockMarketAdapter.getStocks().stream().map(
                        x -> new SelectItem(String.format("%s - %s", x.getTicker(), x.getCompanyName()), String.valueOf(x.getOid()))).collect(Collectors.toList());
            }
            return stockTickers;
        });
    }

    private List<StockPrice> getPrices(StockTicker ticker) {
        var cached = stockPriceCache.getIfPresent(ticker.oid());
        if (cached == null) {
            logger.info(String.format("Populating the stockPrice cache for oid: %d", ticker.oid()));
            cached = stockMarketAdapter.getStockPrices(ticker, null);
            stockPriceCache.put(ticker.oid(), cached);
        }
        return cached;
    }

    public List<StockOptionPurchase> stockOptionPurchases(int purchaseType, int status, String opType) {
        List<StockOptionPurchase> result = stockMarketAdapter.stockOptionPurchases(purchaseType, status, opType);
        return result;
    }

    private Charts charts(StockTicker ticker, ChartFactory factory) {
        var prices = getPrices(ticker);
        return factory.elmCharts(ticker, prices);
    }
    public Either<ApplicationError,Charts> days(StockTicker ticker) {
        return core.handleSearch(() -> charts(ticker, chartFactory));
    }
    public Either<ApplicationError,Charts> weeks(StockTicker ticker) {
        return core.handleSearch(() -> charts(ticker, chartWeekFactory));
    }
    public Either<ApplicationError,Charts> months(StockTicker ticker) {
        return core.handleSearch(() -> charts(ticker, chartMonthFactory));
    }



    public Either<ApplicationError, StockPrice> getSpot(StockTicker stockTicker) {
        return core.handleSearch(() -> stockMarketAdapter.getSpot(stockTicker));
    }


    public void invalidateStockPriceCache() {
        stockPriceCache.invalidateAll();
    }

    public double optionPriceFor(StockOptionTicker ticker, double stockPrice) {
        /*
        var info = StockOptionUtil.stockOptionInfoFromTicker(ticker);
        try {
            //var option = nordnetAdapter.findOption(ticker).getStockOption();
            var option = nordnetAdapter.findOption(ticker).payload().option();

            if (info.third() == CALL) {
                return optionCalculator.callPrice2(stockPrice, option.x(), option.days(), option.ivBid());
            } else {
                return optionCalculator.putPrice2(stockPrice, option.x(), option.days(), option.ivBid());
            }
        }
        catch (RuntimeException ex) {
            logger.error(ex.getMessage());
            return -1.0;
        }

         */
        return 0.0;
    }


    public ApplicationError purchaseOption(StockOptionTicker ticker, int volume) {
        return core.handleSave(() -> {
            stockMarketAdapter.insertPurchase(null);
        },null);
    }

    public StatusDTO purchaseOption(StockOptionPurchase purchase) {
        /*
        var mh = new MyErrorHandler(StatusCode.PURCHASE_STOCK_OPTION_ERROR);
        stockMarketAdapter.insertPurchase(purchase, mh);
        if (mh.get() != null) {
            return mh.get();
        }
        return new StatusDTO(true, String.format("Purchased %s ok", purchase.getTicker()), StatusCode.OK.getStatus());

         */
        return null;
    }
    /*
    public StatusDTO sellOption(StockOptionSale sale) {
        var mh = new MyErrorHandler(StatusCode.SELL_STOCK_OPTION_ERROR);
        stockMarketAdapter.insertSale(sale, mh);
        if (mh.get() != null) {
            return mh.get();
        }
        return new StatusDTO(true, String.format("Sale for purchase id %d ok", sale.getPurchaseOid()), StatusCode.OK.getStatus());
    }

     */

    private String insertSuccessMsg(String ticker, int oid) {
        return String.format("Inserted stockOption purchase ticker: %s, oid: %d", ticker, oid);
    }
    public StatusDTO registerAndPurchaseOption(Tuple2<harborview.domain.stockmarket.StockOption,StockOptionPurchase> purchase) {
        return null;
        /*
        try {
            var mh = new MyErrorHandler(StatusCode.INSERT_STOCK_OPTION_ERROR);
            stockMarketAdapter.insertStockOption(purchase.first(), mh);
            if (mh.get() != null) {
                return mh.get();
            }
            logger.info(String.format("Inserted stockOption: %s", purchase.first().getTicker()));

            purchase.second().setOptionId(purchase.first().getOid());
            stockMarketAdapter.insertPurchase(purchase.second());
            var msg = insertSuccessMsg(purchase.first().getTicker(), purchase.second().getOid());
            logger.info(msg);

            return new StatusDTO(true, msg, StatusCode.OK.getStatus());
        }
        catch (Exception ex) {
            logger.error(String.format("%s for stockOption purchase ticker: %s", ex.getMessage(), purchase.first().getTicker()));
            return new StatusDTO(false, ex.getMessage(), StatusCode.INSERT_DB_ERROR.getStatus());
        }

         */
    }

    static class MyErrorHandler implements Consumer<Exception> {

        final AtomicReference<StatusDTO> status = new AtomicReference<>();
        final StatusCode statusCode;

        public MyErrorHandler(StatusCode statusCode) {
            this.statusCode = statusCode;
        }
        @Override
        public void accept(Exception e) {
            status.set(new StatusDTO(false, e.getMessage(), this.statusCode.getStatus()));
        }

        public StatusDTO get() {
            return status.get();
        }
    }

    /*
    public void demo() {
        var opt = new harborview.domain.stockmarket.StockOption();
        opt.setTicker("YAR3A459.57X");
        opt.setX(459.57);
        opt.setExpiry(java.time.LocalDate.of(2023,1,15));
        opt.setOpType(CALL);
        opt.setStockId(3);
        opt.setSeries("3A");

        stockMarketAdapter.insertStockOption(opt, mh);
        if (mh.get() != null) {
            System.out.println(mh.get());
        }
        System.out.println(opt);
    }

    static Function<Exception,StatusDTO> myHandler() {
        final AtomicReference<StatusDTO> status = new AtomicReference<>();
        return (err) -> {
            status.set(new StatusDTO(false, err.getMessage(), StatusCode.INSERT_DB_ERROR.getStatus()));
            return status.get();
        };
    }
    static Consumer<Exception> myHandler2() {
        final AtomicReference<StatusDTO> status = new AtomicReference<>();
        return (err) -> {
            status.set(new StatusDTO(false, err.getMessage(), StatusCode.INSERT_DB_ERROR.getStatus()));
        };
    }
     */

}
