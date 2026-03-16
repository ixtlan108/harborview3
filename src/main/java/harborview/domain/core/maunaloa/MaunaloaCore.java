package harborview.domain.core.maunaloa;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import harborview.domain.core.Core;
import harborview.domain.error.ApplicationError;
import harborview.domain.functional.Either;
import harborview.domain.stockmarket.StockMarketRepository;
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
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Consumer;
import java.util.stream.Collectors;

import harborview.dto.StatusCode;

@Component
public class MaunaloaCore {

    private Logger logger = LoggerFactory.getLogger(MaunaloaCore.class);
    private final StockMarketRepository stockMarketAdapter;
    private final OptionCalculator optionCalculator;
    private final ChartFactory chartFactory = new ChartFactory();
    private final ChartWeekFactory chartWeekFactory = new ChartWeekFactory();
    private final ChartMonthFactory chartMonthFactory = new ChartMonthFactory();
    Cache<Integer, List<StockPrice>> stockPriceCache = Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .build();

    Cache<Integer, List<RLine>> rlineCache = Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .build();

    private List<SelectItem> stockTickers;

    private final NordnetRepository nordnetRepository;
    private final Core core;

    public MaunaloaCore(@Qualifier("adapter.demo") NordnetRepository nordnetRepository,
    //public MaunaloaCore(NordnetRepository nordnetRepository,
                        StockMarketRepository stockMarketAdapter,
                        Core core,
                        @Qualifier("blackScholes") OptionCalculator optionCalculator) {
        this.nordnetRepository = nordnetRepository;
        this.stockMarketAdapter = stockMarketAdapter;
        this.core = core;
        this.optionCalculator = optionCalculator;
        System.out.println("MaunaloaCore: " + nordnetRepository);
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


    //----------------------------- Risc Lines --------------------------------
    void saveRiscResult(int oid,
                        String ticker,
                        double bid,
                        double ask,
                        double riscValue,
                        double riscStockPrice,
                        double riscOptionPrice,
                        double breakEven) {
        var line = new RLine(oid, ticker, bid, ask, riscValue, riscStockPrice, riscOptionPrice, breakEven);

        var lines = rlineCache.getIfPresent(oid);
        if (lines == null)  {
            logger.info(String.format("Empty rline cache for oid: %d", oid));
            var newLines = new ArrayList<RLine>();
            newLines.add(line);
            rlineCache.put(oid, newLines);
        }
        else {
            logger.info(String.format("Found rline cache for oid: %d", oid));
            lines.add(line);
        }
    }

    RiscResponse calcRiscStockPrice(RiscRequest request) {

        //*
        var info = StockOptionUtil.stockOptionInfoFromTicker(request.getTicker());

        var oid = info.getStockTicker().oid(); //info.first();

        var optionType = info.getStockOptionType(); //info.third();

        var hit = nordnetRepository.findOption(request.getTicker());

        if (hit == null) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.COULD_NOT_FIND_OPTION_ERROR);
        }

        var option = hit.second();

        var riscAdjustedPrice = option.getAsk() - request.getRiscValue();

        if (riscAdjustedPrice < 0) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.RISC_ADJUSTED_PRICE_LESS_THAN_ZERO);
        }

        if (option.getIvBid() < 0) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.IV_LESS_THAN_ZERO);
        }

        double curStockPrice = 0.0;
        double curBreakEven = 0.0;
        var stockPrice = hit.first();
        try {
            curStockPrice = optionCalculator.stockPriceFor2(optionType,
                    riscAdjustedPrice,
                    option.getX(),
                    option.getDays(),
                    option.getIvBid(),
                    stockPrice.cls());
        } catch (BinarySearchException ex) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.CALCULATE_OPTION_PRICE_ERROR);
        }

        try {
            curBreakEven = optionCalculator.stockPriceFor2(optionType,
                    option.getAsk(),
                    option.getX(),
                    option.getDays(),
                    option.getIvBid(),
                    stockPrice.cls());
        } catch (BinarySearchException ex) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.BREAK_EVEN_ERROR);
        }

        var result = new RiscResponse(request.getTicker(), curStockPrice, RiscResponseStatus.OK);

        saveRiscResult(oid,
                request.getTicker().value(),
                option.getBid(),
                option.getAsk(),
                request.getRiscValue(),
                curStockPrice,
                riscAdjustedPrice,
                curBreakEven);

        return result;

        //*/
    }

    public Either<ApplicationError,List<RiscResponse>> calcRiscStockPrices(List<RiscRequest> request) {
        return core.handleSearch(() -> {
            var result = new ArrayList<RiscResponse>();
            for (var risc : request) {
                result.add(calcRiscStockPrice(risc));
            }
            return result;
        });
    }

    public Either<ApplicationError, StockPrice> getSpot(StockTicker stockTicker) {
        return core.handleSearch(() -> stockMarketAdapter.getSpot(stockTicker));
    }

    public List<RLine> getRiscLines(StockTicker ticker) {
        var lines = rlineCache.getIfPresent(ticker.oid());
        if (lines == null) {
            return Collections.emptyList();
        }
        else {
            return lines;
        }
    }
    public StatusDTO deleteAllRiscLines(StockTicker ticker) {
        rlineCache.invalidate(ticker.oid());
        return new StatusDTO(true, String.format("Deleted risc lines for %s ok", ticker.ticker()), StatusCode.OK.getStatus());
    }

    public void invalidateRiscLineCache() {
        rlineCache.invalidateAll();
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
        return null;
    }

    public StatusDTO purchaseOption(StockOptionPurchase purchase) {
        var mh = new MyErrorHandler(StatusCode.PURCHASE_STOCK_OPTION_ERROR);
        stockMarketAdapter.insertPurchase(purchase, mh);
        if (mh.get() != null) {
            return mh.get();
        }
        return new StatusDTO(true, String.format("Purchased %s ok", purchase.getTicker()), StatusCode.OK.getStatus());
    }
    public StatusDTO sellOption(StockOptionSale sale) {
        var mh = new MyErrorHandler(StatusCode.SELL_STOCK_OPTION_ERROR);
        stockMarketAdapter.insertSale(sale, mh);
        if (mh.get() != null) {
            return mh.get();
        }
        return new StatusDTO(true, String.format("Sale for purchase id %d ok", sale.getPurchaseOid()), StatusCode.OK.getStatus());
    }

    private String insertSuccessMsg(String ticker, int oid) {
        return String.format("Inserted stockOption purchase ticker: %s, oid: %d", ticker, oid);
    }
    public StatusDTO registerAndPurchaseOption(Tuple2<harborview.domain.stockmarket.StockOption,StockOptionPurchase> purchase) {
        try {
            var mh = new MyErrorHandler(StatusCode.INSERT_STOCK_OPTION_ERROR);
            stockMarketAdapter.insertStockOption(purchase.first(), mh);
            if (mh.get() != null) {
                return mh.get();
            }
            logger.info(String.format("Inserted stockOption: %s", purchase.first().getTicker()));

            purchase.second().setOptionId(purchase.first().getOid());
            stockMarketAdapter.insertPurchase(purchase.second(), null);
            var msg = insertSuccessMsg(purchase.first().getTicker(), purchase.second().getOid());
            logger.info(msg);

            return new StatusDTO(true, msg, StatusCode.OK.getStatus());
        }
        catch (Exception ex) {
            logger.error(String.format("%s for stockOption purchase ticker: %s", ex.getMessage(), purchase.first().getTicker()));
            return new StatusDTO(false, ex.getMessage(), StatusCode.INSERT_DB_ERROR.getStatus());
        }
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
