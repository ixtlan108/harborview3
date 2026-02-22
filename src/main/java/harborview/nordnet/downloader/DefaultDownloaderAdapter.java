package harborview.nordnet.downloader;

import harborview.nordnet.stockmarket.StockOptionInfo;
import harborview.nordnet.stockmarket.StockTicker;
import harborview.nordnet.util.NordnetUtil;
import org.apache.hc.core5.http.HttpStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;

@Component("default")
public class DefaultDownloaderAdapter implements  Downloader<PageInfo> {
    private final Logger logger = LoggerFactory.getLogger(DefaultDownloaderAdapter.class);

    private HttpClient client;


    public DefaultDownloaderAdapter() {
    }

    @Override
    public List<PageInfo> download(StockTicker ticker) {
        /*
        var nordnetMillis = redisAdapter.nordnetMillisForUrl(LocalDate.now());

        var result = new ArrayList<PageInfo>();

        for (var nm : nordnetMillis) {
            try {
                var page = download(ticker, nm);
                result.add(page);
            }
            catch (DownloadException e) {
                logger.warn(String.format("(%s) Could not download, status: %d", e.getUrl(), e.getHttpStatus()));
            }
        }

         */
        var result = new ArrayList<PageInfo>();
        try {
            var page = download(ticker, 1781820000000L);
            result.add(page);
        }
        catch (DownloadException e) {
            logger.warn(String.format("(%s) Could not download, status: %d", e.getUrl(), e.getHttpStatus()));
        }

        return result;
    }


    @Override
    public PageInfo download(StockOptionInfo info) {
        return download(info.getStockTicker(), info.getNordnetMillis());
    }

    PageInfo download(StockTicker ticker, long nordnetMillis) {
        try {
            var url = NordnetUtil.urlFor(ticker, nordnetMillis);
            var req =
                    HttpRequest.newBuilder(url.toURI()).GET().build();
            //var h = new HttpHead(url.toString());
            HttpResponse<String> response = getClient().send(req, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != HttpStatus.SC_OK) {
                throw new DownloadException(url, response.statusCode());
            }
            return new PageInfo(response.body());
        } catch (IOException | InterruptedException | URISyntaxException e) {
            throw new RuntimeException(e);
        }
    }

    private HttpClient getClient() {
        if (client == null) {
            client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_2).build();
        }
        return client;
    }
}
