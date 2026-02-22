package harborview.nordnet.repository;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import harborview.adapter.RedisAdapter;
import harborview.nordnet.*;
import harborview.nordnet.downloader.Downloader;
import harborview.nordnet.downloader.PageInfo;
import harborview.nordnet.stockmarket.StockOption;
import harborview.nordnet.stockmarket.StockOptionTicker;
import harborview.nordnet.stockmarket.StockPrice;
import harborview.nordnet.stockmarket.StockTicker;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;
import vega.financial.StockOptionType;
import vega.financial.calculator.OptionCalculator;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.TimeUnit;


@Component
@Primary
public class NordnetAdapterV1 extends NordnetAdapterBase implements NordnetRepository {

    private final RedisAdapter redisAdapter;
    private final OptionCalculator blackScholes;
    private final boolean fetchOpeningPrice;
    private final LocalDate curDate;
    private final Cache<Integer, Tuple2<StockPrice,List<StockOption>>> cacheStockOptions;
    private final Cache<String, Tuple2<StockPrice,List<StockOption>>> cacheStockOption;

    public NordnetAdapterV1(Downloader<PageInfo> downloader,
                            RedisAdapter redisAdapter,
                            @Qualifier("blackScholes") OptionCalculator blackScholes,
                            @Value("${curdate:#{null}}") String curDateStr,
                            @Value("${cache.options.expiry}") int optionsExpiry,
                            @Value("${cache.option.expiry}") int optionExpiry,
                            @Value("${redis.fetchOpeningPrice}") boolean fetchOpeningPrice) {
        super(downloader);
        this.redisAdapter = redisAdapter;
        this.blackScholes = blackScholes;
        this.fetchOpeningPrice = fetchOpeningPrice;

        curDate = getDateFor(curDateStr,null);

        cacheStockOptions = Caffeine.newBuilder().expireAfterWrite(optionsExpiry, TimeUnit.MINUTES).build();
        cacheStockOption = Caffeine.newBuilder().expireAfterWrite(optionExpiry, TimeUnit.SECONDS).build();
    }

    @Override
    public List<StockOption> getCalls(StockTicker ticker) {
        return getOptions(ticker, StockOptionType.CALL);
    }

    @Override
    public List<StockOption> getPuts(StockTicker ticker) {
        return List.of();
    }

    @Override
    public StockPrice getStockPrice(StockTicker ticker) {
        return null;
    }

    @Override
    public Tuple2<StockPrice, StockOption> findOption(StockOptionTicker ticker) {
        return null;
    }

    @Override
    public void resetCaffeine() {

    }

    private List<StockOption> getOptions(StockTicker ticker, StockOptionType ot) {
        var result = parse(ticker);
        if (result == null) {
            return Collections.emptyList();
        }
        return result.second().stream().filter(x -> x.getOpType() == ot).toList();
    }
    private Tuple2<StockPrice,List<StockOption>> parse(StockTicker ticker) {
        return null;
    }
}
