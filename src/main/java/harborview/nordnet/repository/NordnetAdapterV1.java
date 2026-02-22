package harborview.nordnet.repository;

import harborview.nordnet.*;
import harborview.nordnet.downloader.Downloader;
import harborview.nordnet.downloader.PageInfo;
import harborview.nordnet.stockmarket.StockOption;
import harborview.nordnet.stockmarket.StockOptionTicker;
import harborview.nordnet.stockmarket.StockPrice;
import harborview.nordnet.stockmarket.StockTicker;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import java.util.List;


@Component
public class NordnetAdapterV1 extends NordnetAdapterBase implements NordnetRepository {

    public NordnetAdapterV1(@Qualifier("default") Downloader<PageInfo> downloader) {
        super(downloader);
    }

    @Override
    public List<StockOption> getCalls(StockTicker ticker) {
        return List.of();
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
}
