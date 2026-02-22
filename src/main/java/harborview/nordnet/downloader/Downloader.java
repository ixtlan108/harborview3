package harborview.nordnet.downloader;


import harborview.nordnet.stockmarket.StockOptionInfo;
import harborview.nordnet.stockmarket.StockTicker;

import java.util.List;

public interface Downloader<T> {
    List<T> download(StockTicker ticker);
    T download(StockOptionInfo info);
}
