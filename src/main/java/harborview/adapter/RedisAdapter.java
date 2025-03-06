package harborview.adapter;


import harborview.domain.stockmarket.StockPrice;
import harborview.domain.stockmarket.StockTicker;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneOffset;

@Component
public class RedisAdapter {

    private final RedisTemplate<String,Object> redisTemplate;

    public RedisAdapter(RedisTemplate<String,Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    private double getPrice(StockTicker ticker, String redisKey) {
        var result = (String) redisTemplate.opsForHash().get(redisKey,
                String.format("%d", ticker.oid()));
        return Double.parseDouble(result);
    }

    /*
    public long getUnixTime() {
        return LocalDate.now().atStartOfDay().toInstant(ZoneOffset.UTC).toEpochMilli();
    }

     */

    public StockPrice getSpot(StockTicker ticker) {
        var opn = getPrice(ticker, "stockprice:open");
        var hi = getPrice(ticker, "stockprice:hi");
        var lo = getPrice(ticker, "stockprice:lo");
        var cls = getPrice(ticker, "stockprice:close");
        return new StockPrice(LocalDate.now(), opn, hi, lo, cls, 1000);
    }
}

