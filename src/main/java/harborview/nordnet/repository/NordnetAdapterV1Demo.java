package harborview.nordnet.repository;

import harborview.adapter.RedisAdapter;
import harborview.nordnet.downloader.Downloader;
import harborview.nordnet.downloader.PageInfo;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import vega.financial.calculator.OptionCalculator;

@Component
@Profile("demo")
public class NordnetAdapterV1Demo extends NordnetAdapterV1 {


    public NordnetAdapterV1Demo(@Qualifier("demo") Downloader<PageInfo> downloader,
                                RedisAdapter redisAdapter,
                                @Qualifier("blackScholes") OptionCalculator blackScholes,
                                @Value("${curdate:#{null}}") String curDateStr,
                                @Value("${cache.options.expiry}") int optionsExpiry,
                                @Value("${cache.option.expiry}") int optionExpiry,
                                @Value("${redis.fetchOpeningPrice}") boolean fetchOpeningPrice) {
        super(downloader,redisAdapter,blackScholes,curDateStr,optionsExpiry,optionExpiry,fetchOpeningPrice);
    }

}
