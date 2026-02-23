package harborview.nordnet.repository;

import harborview.nordnet.stockmarket.StockOption;
import harborview.nordnet.stockmarket.StockOptionTicker;
import harborview.nordnet.stockmarket.StockPrice;
import harborview.nordnet.stockmarket.StockTicker;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class NordnetAdapterV1FileSystemTest {


    @Autowired
    NordnetAdapterV1FileSystem nordnetAdapter;

    private final StockTicker stockTicker = new StockTicker("YAR");

    @Test
    void test_parse_filesystem() {
        var stockPrice = nordnetAdapter.getStockPrice(stockTicker);
        checkStockPrice(stockPrice);
        var calls = nordnetAdapter.getCalls(stockTicker);
        assertEquals(19, calls.size());
        var puts = nordnetAdapter.getPuts(stockTicker);
        assertEquals(19, puts.size());

        checkStockOption("YAR6L600", 3.55, 6.20, 600, calls);
        checkStockOption("YAR6L500", 20.00, 23.80, 500, calls);
        checkStockOption("YAR6L360", 105.00, 114.20, 360, calls);
        checkStockOption("YAR6L260", 196.20, 214.60, 260, calls);

        checkStockOption("YAR6X600", 148.40, 157.40, 600, puts);
        checkStockOption("YAR6X500", 61.60, 70.80, 500, puts);
        checkStockOption("YAR6X360", 7.00, 10.10, 360, puts);
        checkStockOption("YAR6X260", 0.25, 2.95, 260, puts);
    }

    @Test
    void test_find_option() {

        var ticker = new StockOptionTicker("YAR6L480");
        var option = nordnetAdapter.findOption(ticker);
        assertNotNull(option);
        checkStockPrice(option.first());
        checkStockOption(option.second(),27.00, 31.00, 480, 0.1, 0.29, true);


        var ticker2 = new StockOptionTicker("YAR6X580");
        var option2 = nordnetAdapter.findOption(ticker2);
        assertNotNull(option2);
        checkStockOption(option2.second(),129.20, 138.80, 580, 0.75, 0.83, true);
    }

    /*
    @Test
    void test_opening_price() {
        var price = nordnetAdapter.openingPrice(stockTicker);
        assertEquals(341.9, price.price(), 0.1);
    }

     */

    private void checkStockPrice(StockPrice stockPrice) {
        //assertEquals(403.0, stockPrice.opn(), 0.1);
        assertEquals(466.7, stockPrice.hi(), 0.1);
        assertEquals(460.3, stockPrice.lo(), 0.1);
        assertEquals(463.7, stockPrice.cls(), 0.1);
    }

    private void checkStockOption(StockOption option,
                                  double bid,
                                  double ask,
                                  double x,
                                  double ivBid,
                                  double ivAsk,
                                  boolean skipIv) {
        assertEquals(bid, option.getBid(), 0.01);
        assertEquals(ask, option.getAsk(), 0.01);
        assertEquals(x, option.getX(), 0.001);
        if (!skipIv) {
            assertEquals(ivBid, option.getIvBid(), 0.01);
            assertEquals(ivAsk, option.getIvAsk(), 0.01);
        }
    }

    private void checkStockOption(String tickerS,
                                  double bid,
                                  double ask,
                                  double x,
                                  List<StockOption> options) {

        var opt = options.stream().filter(s -> s.getTicker().value().equals(tickerS)).findFirst();
        assertFalse(opt.isEmpty());
        var o = opt.get();
        assertEquals(bid, o.getBid(), 0.01);
        assertEquals(ask, o.getAsk(), 0.01);
        assertEquals(x, o.getX(), 0.001);
    }
}
