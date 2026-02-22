package harborview.nordnet.downloader;

import harborview.nordnet.stockmarket.StockOptionInfo;
import harborview.nordnet.stockmarket.StockTicker;
import org.springframework.stereotype.Component;

import java.util.List;

@Component("nordnet")
public class IntegrationRealDownloaderAdapter implements  Downloader<PageInfo> {

    @Override
    public List<PageInfo> download(StockTicker ticker) {
        return List.of();
    }

    @Override
    public PageInfo download(StockOptionInfo info) {
        return null;
    }
}
