package harborview.nordnet.util;


import harborview.nordnet.stockmarket.StockOptionTicker;
import harborview.nordnet.stockmarket.StockTicker;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

public class NordnetUtil {

    private final static ZoneId zoneId = ZoneId.of("Europe/Oslo");

    public static long calcUnixTimeForThirdFriday(YearMonthDTO yearMonth) {
        var thirdFriday = StockOptionUtil.thirdFriday(yearMonth.year(), yearMonth.month());

        var ldt = LocalDateTime.of(thirdFriday.getYear(), thirdFriday.getMonth(), thirdFriday.getDayOfMonth(), 0, 0, 0);

        var offset = zoneId.getRules().getOffset(ldt);

        return ldt.toInstant(offset).toEpochMilli();
    }

    public static URL urlFor(StockOptionTicker ticker ) {
        try {
            var info = StockOptionUtil.stockOptionInfoFromTicker(ticker);
            return new URL ("https","www.nordnet.no", pathQueryFor(info.getStockTicker(), info.getNordnetMillis()));
        } catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }
    }

    public static URL urlFor(StockTicker ticker, long nordnetMillis) {
        try {
            return new URL ("https","www.nordnet.no", pathQueryFor(ticker, nordnetMillis));
        } catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }
    }

    private static String pathQueryFor(StockTicker ticker, long nordnetMillis) {
        return String.format("/derivat/opsjoner/liste?currency=NOK&underlyingSymbol=%s&expireDate=%d",  ticker.ticker(), nordnetMillis);
        //return String.format("/market/options?currency=NOK&underlyingSymbol=%s&expireDate=%d",  ticker.ticker(), nordnetMillis);
        //https://www.nordnet.no/derivat/opsjoner/liste?currency=NOK&underlyingSymbol=YAR&expireDate=1766098800000
    }
    /*
   scheme:[//authority]path[?query][#fragment]
     */

    private static YearMonthDTO yearMonthFor(LocalDate ld) {

        var year = ld.getYear();
        var month = ld.getMonthValue();
        return new YearMonthDTO(year,month);

    }

    public static List<YearMonthDTO> yearMonthForDate(LocalDate curDate)  {
        var m1 = yearMonthFor(curDate);
        var m2 = yearMonthFor(curDate.plusMonths(1));
        var m3 = yearMonthFor(curDate.plusMonths(2));
        var m4 = yearMonthFor(curDate.plusMonths(3));
        var d5 = curDate.plusMonths(4);
        var m5 = yearMonthFor(d5);
        var m8 = yearMonthFor(d5.plusMonths(3));
        var m11 = yearMonthFor(d5.plusMonths(6));
        return List.of(m1,m2,m3,m4,m5,m8,m11);
    }

    public static List<Long> nordnetMillisForDate(LocalDate curDate)  {
        // Pattern: f.o.m denne mnd + de neste 4, deretter 3 og 9 mnd etterpå, deretter 6 og 12 mnd etter på
        // Pattern: < 1 mnd, 1 - 3 mnd (hver mnd), 3 - 6 mnd, 1 - 3 år
        var ymd = yearMonthForDate(curDate);

        var ymd1 = ymd.getFirst();

        var currentMonthsThirdFriday = StockOptionUtil.thirdFriday(ymd1.year(),ymd1.month());

        if (curDate.plusDays(14).isAfter(currentMonthsThirdFriday)) {
            return ymd.stream().map(NordnetUtil::calcUnixTimeForThirdFriday).skip(1).toList();
        }
        else {
            return ymd.stream().map(NordnetUtil::calcUnixTimeForThirdFriday).toList();
        }

    }
}
