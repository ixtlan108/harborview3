package harborview.nordnet.downloader;

import harborview.nordnet.stockmarket.StockOptionInfo;
import harborview.nordnet.stockmarket.StockTicker;
import org.htmlunit.WebClient;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@Component("filesystem")
public class IntegrationDownloaderAdapter implements  Downloader<PageInfo> {

    private final WebClient client;

    private List<PageInfo> result = null;

    private final String jsoupUurl = "file:///home/rcs/opt/java/harborview3/src/integration/resources/nordnet/jsoup.html";

    public IntegrationDownloaderAdapter() {
        this.client = new WebClient();
        this.client.getOptions().setJavaScriptEnabled(false);
    }

    @Override
    public List<PageInfo> download(StockTicker ticker) {
        if (result == null) {

            try {
                var page = client.getPage(jsoupUurl);
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
        return null;
    }
}
