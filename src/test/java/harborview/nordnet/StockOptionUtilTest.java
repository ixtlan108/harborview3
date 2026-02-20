package harborview.nordnet;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.time.LocalDate;
import java.util.stream.Stream;

import static harborview.nordnet.StockOptionInfo.StatusEnum.OK;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static vega.financial.StockOptionType.CALL;
import static vega.financial.StockOptionType.PUT;

public class StockOptionUtilTest {

    @Test
    void test_iso_8601() {
        assertEquals("2024-04-09", StockOptionUtil.iso8601(LocalDate.of(2024,4,9)));
        assertEquals("2024-11-16", StockOptionUtil.iso8601(LocalDate.of(2024,11,16)));
    }

    @Test
    void test_iso_8601_and_days() {
        var ticker = new StockOptionTicker("YAR4C220");
        var curDate = LocalDate.of(2023,12,11);
        var result = StockOptionUtil.iso8601andDays(ticker, curDate);
        assertEquals("2024-03-15", result.first());
        assertEquals(95, result.second());
    }

    @Test
    void test_nordnet_millis() {
        var testDate = LocalDate.of(2023, 3, 30);
        assertEquals(1680127200000L, StockOptionUtil.nordnetMillis(testDate));
    }

    @ParameterizedTest
    @MethodSource("stockOptionInfoSource")
    void test_stock_option_info(StockOptionTicker ticker, long nordnetMillis, StockOptionInfo info) {
        var actual = StockOptionUtil.stockOptionInfoFromTicker(ticker);
        assertEquals(info.getStatus(), actual.getStatus());
        assertEquals(info.getStockOptionTicker().value(), actual.getStockOptionTicker().value());
        assertEquals(info.getStockTicker().ticker(), actual.getStockTicker().ticker());
        assertEquals(info.getYear(), actual.getYear());
        assertEquals(info.getMonth(), actual.getMonth());
        assertEquals(nordnetMillis, actual.getNordnetMillis());
        assertEquals(info.getStockOptionType(), actual.getStockOptionType());

    }

    private static Stream<Arguments> stockOptionInfoSource() {
        return Stream.of(
          Arguments.of("EQNR3C428.99Z",  1679007600000L, new StockOptionInfo(OK, new StockTicker("EQNR"), new StockOptionTicker("EQNR3C428.99Z"),2023, 3, CALL)),
                Arguments.of("EQNR3O428.99Z", 1679007600000L, new StockOptionInfo(OK, new StockTicker("EQNR"), new StockOptionTicker("EQNR3O428.99Z"),2023, 3, PUT)),
                Arguments.of("NHY3F50.79X", 1686866400000L, new StockOptionInfo(OK, new StockTicker("NHY"), new StockOptionTicker("NHY3F50.79X"),2023, 6, CALL)),
                Arguments.of("NHY3R140", 1686866400000L, new StockOptionInfo(OK, new StockTicker("NHY"), new StockOptionTicker("NHY3R140"),2023, 6, PUT)),
                Arguments.of("YAR3L380", 1702594800000L, new StockOptionInfo(OK, new StockTicker("YAR"), new StockOptionTicker("YAR3L380"),2023, 12, CALL)),
                Arguments.of("YAR3X380", 1702594800000L, new StockOptionInfo(OK, new StockTicker("YAR"), new StockOptionTicker("YAR3X380"),2023, 12, PUT))
        );
    }

}
