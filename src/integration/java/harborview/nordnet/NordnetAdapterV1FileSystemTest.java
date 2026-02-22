package harborview.nordnet;

import harborview.nordnet.downloader.IntegrationDownloaderAdapter;
import harborview.nordnet.repository.NordnetAdapterV1;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class NordnetAdapterV1FileSystemTest {


    @Autowired
    NordnetAdapterV1 nordnetAdapter;

    @Autowired
    IntegrationDownloaderAdapter downloaderAdapter;

    @Test
    void test_parse_real_time() {
    }
}
