package harborview.nordnet;


import java.util.List;

public interface Downloader<T> {
    List<T> download(StockTicker ticker);
    //T download(StockOptionTicker ticker);
    //T downloadOne(StockTicker ticker);
    T download(StockOptionInfo info);
}
