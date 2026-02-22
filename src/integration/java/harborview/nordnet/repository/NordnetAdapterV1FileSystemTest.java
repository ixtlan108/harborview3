package harborview.nordnet.repository;

import harborview.nordnet.stockmarket.StockTicker;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class NordnetAdapterV1FileSystemTest {


    @Autowired
    NordnetAdapterV1FileSystem nordnetAdapter;

    @Test
    void test_parse_filesystem() {
        var calls = nordnetAdapter.getCalls(new StockTicker("YAR"));
        System.out.println(calls);
    }
}
