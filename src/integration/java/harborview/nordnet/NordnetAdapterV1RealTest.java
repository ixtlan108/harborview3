package harborview.nordnet;

import harborview.nordnet.downloader.IntegrationDownloaderAdapter;
import harborview.nordnet.downloader.IntegrationRealDownloaderAdapter;
import harborview.nordnet.repository.NordnetAdapterV1;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class NordnetAdapterV1RealTest {

    @Autowired
    NordnetAdapterV1 nordnetAdapter;

    @Autowired
    IntegrationRealDownloaderAdapter downloaderAdapter;

    @Test
    void test_parse_real_time() {
    }
}
