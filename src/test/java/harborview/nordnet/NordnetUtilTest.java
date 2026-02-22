package harborview.nordnet;

import harborview.nordnet.stockmarket.StockOptionTicker;
import harborview.nordnet.util.NordnetUtil;
import harborview.nordnet.util.StockOptionUtil;
import harborview.nordnet.util.YearMonthDTO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class NordnetUtilTest {
    /*
        2024-02-16: 1708038000000 but got: 1708041600000
        2024-03-15: 1710457200000
        2024-04-19: 1713477600000
        2024-06-21: 1718920800000L
        2024-09-20: 1726783200000L
        2024-12-20: 1734649200000L
     */
    private static Stream<Arguments> yearsAndMonthsSource() {
        return Stream.of(
                Arguments.of(new YearMonthDTO(2024,2), 1708038000000L),
                Arguments.of(new YearMonthDTO(2024,3), 1710457200000L),
                Arguments.of(new YearMonthDTO(2024,4), 1713477600000L),
                Arguments.of(new YearMonthDTO(2024,6), 1718920800000L),
                Arguments.of(new YearMonthDTO(2024,9), 1726783200000L),
                Arguments.of(new YearMonthDTO(2024,12), 1734649200000L),
                Arguments.of(new YearMonthDTO(2026,2), 1771542000000L),
                Arguments.of(new YearMonthDTO(2026,3), 1773961200000L),
                Arguments.of(new YearMonthDTO(2026,4), 1776376800000L),
                Arguments.of(new YearMonthDTO(2026,5), 1778796000000L),
                Arguments.of(new YearMonthDTO(2026,6), 1781820000000L),
                Arguments.of(new YearMonthDTO(2026,9), 1789682400000L),
                Arguments.of(new YearMonthDTO(2026,12), 1797548400000L),
                Arguments.of(new YearMonthDTO(2027,6), 1813269600000L),
                Arguments.of(new YearMonthDTO(2027,12),1828998000000L)

        );
    }

    @ParameterizedTest
    @MethodSource("yearsAndMonthsSource")
    void test_nordnet_millis_collection_from_years_and_months(YearMonthDTO yearMonth, long expected) {
        var actual = NordnetUtil.calcUnixTimeForThirdFriday(yearMonth);
        assertEquals(expected, actual);
    }

    @Test
    void test_url_for_stock_ticker() throws MalformedURLException {
        var ticker = new StockOptionTicker("NHY6L80");
        var info = StockOptionUtil.stockOptionInfoFromTicker(ticker);
        var actual = NordnetUtil.urlFor(info.getStockTicker(), info.getNordnetMillis());
        var expected = new URL("https", "www.nordnet.no", "/derivat/opsjoner/liste?currency=NOK&underlyingSymbol=NHY&expireDate=1797548400000");
        assertEquals(expected, actual);
    }
    @Test
    void test_url_for_stockoption_ticker() throws MalformedURLException {
        var ticker = new StockOptionTicker("NHY6L80");
        var actual = NordnetUtil.urlFor(ticker);
        var expected = new URL("https", "www.nordnet.no", "/derivat/opsjoner/liste?currency=NOK&underlyingSymbol=NHY&expireDate=1797548400000");
        //var expected = new URL("https", "www.nordnet.no", "/market/options?currency=NOK&underlyingSymbol=YAR&expireDate=1702594800000");
        assertEquals(expected, actual);
    }
    @Test
    void test_nordnet_millis_for_date() throws MalformedURLException {

        var curDate = LocalDate.of(2026,2,19);
        //var curDate = LocalDate.of(2026,3,31);

        /*
        var expected = List.of(new YearMonthDTO(2026,3),
                new YearMonthDTO(2026,4),
                new YearMonthDTO(2026,5),
                new YearMonthDTO(2026,6),
                new YearMonthDTO(2026,9),
                new YearMonthDTO(2026,12),
                new YearMonthDTO(2027,6),
                new YearMonthDTO(2027,12));

        var expected = List.of(1771542000000L,1773961200000L,
                1776376800000L,1778796000000L,1781820000000L,
                1789682400000L,1797548400000L);
         */

        var expected = List.of(1773961200000L,
                1776376800000L,1778796000000L,1781820000000L,
                1789682400000L,1797548400000L);

        //1789682400000L,1797548400000L,1813269600000L,1828998000000L);

        var actual = NordnetUtil.nordnetMillisForDate(curDate);

        assertEquals(expected,actual);

    }
}