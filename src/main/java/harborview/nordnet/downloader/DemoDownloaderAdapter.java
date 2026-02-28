package harborview.nordnet.downloader;

import harborview.nordnet.stockmarket.StockOptionInfo;
import harborview.nordnet.stockmarket.StockTicker;
import org.htmlunit.WebClient;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@Component("demo")
public class DemoDownloaderAdapter implements  Downloader<PageInfo> {

    private final WebClient client;

    private List<PageInfo> result = null;

    public DemoDownloaderAdapter() {
        this.client = new WebClient();
        this.client.getOptions().setJavaScriptEnabled(false);
    }

    @Override
    public List<PageInfo> download(StockTicker ticker) {
        if (result == null) {

            try {
                String jsoupUrl = "file:///home/rcs/opt/java/harborview3/src/integration/resources/nordnet/jsoup-1797548400.html";
                var page = client.getPage(jsoupUrl);
                var content = page.getWebResponse().getContentAsString();
                var info = new PageInfo(content);

                result = Collections.singletonList(info);

            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        return result;
    }

    @Override
    public PageInfo download(StockOptionInfo info) {
        return download(info.getStockTicker()).getFirst();
    }
}
