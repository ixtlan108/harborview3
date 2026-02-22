package harborview.nordnet.repository;

import harborview.nordnet.stockmarket.StockOption;
import harborview.nordnet.stockmarket.StockPrice;
import harborview.nordnet.stockmarket.StockTicker;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

//@Disabled
@SpringBootTest
public class NordnetAdapterV1RealTest {

    @Autowired
    NordnetAdapterV1 nordnetAdapter;

    private final StockTicker stockTicker = new StockTicker("YAR");

    @Test
    void test_parse_real_time() {
        var calls = nordnetAdapter.getCalls(stockTicker);
        checkCalls(calls);
        var stockPrice = nordnetAdapter.getStockPrice(stockTicker);
        checkStockPrice(stockPrice);
    }

    private void checkStockPrice(StockPrice stockPrice) {
        assertNotNull(stockPrice);
        //assertTrue(stockPrice.opn() > 0);
        assertTrue(stockPrice.hi() > 0);
        assertTrue(stockPrice.lo() > 0);
        assertTrue(stockPrice.cls() > 0);
    }
    private void checkCalls(List<StockOption> calls) {
        assertNotNull(calls);
        assertFalse(calls.isEmpty());
    }
}
