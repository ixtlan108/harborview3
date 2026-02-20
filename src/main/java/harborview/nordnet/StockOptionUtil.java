package harborview.nordnet;

import harborview.nordnet.StockTicker;
import harborview.nordnet.StockOptionInfo;
import harborview.nordnet.StockOptionTicker;
import harborview.nordnet.Tuple2;
import vega.financial.StockOptionType;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.chrono.ChronoLocalDateTime;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.Map;
import java.util.regex.Pattern;

import static harborview.nordnet.StockOptionInfo.StatusEnum.OK;
import static vega.financial.StockOptionType.CALL;
import static vega.financial.StockOptionType.PUT;


public class StockOptionUtil {
    static ZoneId EUROPE_OSLO = ZoneId.of("Europe/Oslo");
    static Pattern pat = Pattern.compile("(\\D+)(\\d)(\\D)\\.*", Pattern.CASE_INSENSITIVE);
    private static final Map<String, Tuple2<StockOptionType, Integer>> str2optInfo =
            Map.ofEntries(
                Map.entry("A", new Tuple2<>(CALL,1)),
                    Map.entry("B", new Tuple2<>(CALL,2)),
                    Map.entry("C", new Tuple2<>(CALL,3)),
                    Map.entry("D", new Tuple2<>(CALL,4)),
                    Map.entry("E", new Tuple2<>(CALL,5)),
                    Map.entry("F", new Tuple2<>(CALL,6)),
                    Map.entry("G", new Tuple2<>(CALL,7)),
                    Map.entry("H", new Tuple2<>(CALL,8)),
                    Map.entry("I", new Tuple2<>(CALL,9)),
                    Map.entry("J", new Tuple2<>(CALL,10)),
                    Map.entry("K", new Tuple2<>(CALL,11)),
                    Map.entry("L", new Tuple2<>(CALL,12)),
                    Map.entry("M", new Tuple2<>(PUT,1)),
                    Map.entry("N", new Tuple2<>(PUT,2)),
                    Map.entry("O", new Tuple2<>(PUT,3)),
                    Map.entry("P", new Tuple2<>(PUT,4)),
                    Map.entry("Q", new Tuple2<>(PUT,5)),
                    Map.entry("R", new Tuple2<>(PUT,6)),
                    Map.entry("S", new Tuple2<>(PUT,7)),
                    Map.entry("T", new Tuple2<>(PUT,8)),
                    Map.entry("U", new Tuple2<>(PUT,9)),
                    Map.entry("V", new Tuple2<>(PUT,10)),
                    Map.entry("W", new Tuple2<>(PUT,11)),
                    Map.entry("X", new Tuple2<>(PUT,12))
            );
    private static final Map<String,Integer> str2year =
            Map.ofEntries(
                    Map.entry("2", 2022),
                    Map.entry("3", 2023),
                    Map.entry("4", 2024),
                    Map.entry("5", 2025),
                    Map.entry("6", 2026),
                    Map.entry("7", 2027),
                    Map.entry("8", 2028),
                    Map.entry("9", 2029));
    private static final Map<Integer,String> oid2str = Map.ofEntries(
            Map.entry(18,"AKSO"),
            Map.entry(27,"BAKKA"),
            Map.entry(26, "BWLPG"),
            Map.entry(19, "DNB"),
            Map.entry(20, "DNO"),
            Map.entry(2, "EQNR"),
            Map.entry(21, "GJF"),
            Map.entry(28, "GOGL"),
            Map.entry(1,  "NHY"),
            Map.entry(29, "NAS"),
            Map.entry(7,  "OBX"),
            Map.entry(9,  "ORK"),
            Map.entry(12, "PGS"),
            Map.entry(14, "STB"),
            Map.entry(23, "SUBC"),
            Map.entry(6,  "TEL"),
            Map.entry(16, "TGS"),
            Map.entry(17, "TOM"),
            Map.entry(3,  "YAR")
    );
    private static final Map<String, Integer> str2oid = Map.ofEntries(
            Map.entry("AKSO", 18),
            Map.entry("BAKKA", 27),
            Map.entry("BWLPG", 26),
            Map.entry("DNB", 19),
            Map.entry("DNO", 20),
            Map.entry("EQNR", 2),
            Map.entry("GJF", 21),
            Map.entry("GOGL", 28),
            Map.entry("NHY", 1),
            Map.entry("NAS", 29),
            Map.entry("OBX", 7),
            Map.entry("ORK", 9),
            Map.entry("PGS", 12),
            Map.entry("STB", 14),
            Map.entry("SUBC", 23),
            Map.entry("TEL", 6),
            Map.entry("TGS", 16),
            Map.entry("TOM", 17),
            Map.entry( "YAR", 3)
    );

    public static long nordnetMillis(LocalDate dx) {
        ChronoLocalDateTime<LocalDate> tm = dx.atStartOfDay();
        var zone = tm.atZone(EUROPE_OSLO);
        var epoch = zone.toEpochSecond();
        return epoch*1000;
    }
    public static long nordnetMillis(int year, int month) {
        var dx = thirdFriday(year, month);
        return nordnetMillis(dx);
    }

    public static LocalDate thirdFriday(int year, int month) {
        return LocalDate.of(year, month, 1).
                with(TemporalAdjusters.dayOfWeekInMonth(3, DayOfWeek.FRIDAY));
    }

    public static StockOptionInfo stockOptionInfoFromTicker(StockOptionTicker ticker) {
        var m = pat.matcher(ticker.value());
        if (m.find()) {
            var info = str2optInfo.get(m.group(3));
            if (info == null) {
                return StockOptionInfo.err();
            }
            var stik = m.group(1);
            var year = str2year.get(m.group(2));
            var month = info.second();
            var stockTicker = new StockTicker(stik);
            var ot = info.first();
            return new StockOptionInfo(OK, stockTicker, ticker, year, month, ot);
        }
        return StockOptionInfo.err();
    }



    public static String mapOid(int value) {
        return oid2str.get(value);
    }
    public static int mapString(String value) {
        return str2oid.get(value);
    }

    public static String iso8601(LocalDate ld) {
        var month = ld.getMonthValue() < 10 ?
                String.format("0%d", ld.getMonthValue()) :
                String.format("%d", ld.getMonthValue());
        var day = ld.getDayOfMonth() < 10 ?
                String.format("0%d", ld.getDayOfMonth()) :
                String.format("%d", ld.getDayOfMonth());
        return String.format("%d-%s-%s", ld.getYear(), month, day);
    }
    public static Tuple2<String,Long> iso8601andDays(StockOptionTicker ticker, LocalDate curDate) {
        var info = stockOptionInfoFromTicker(ticker);
        var friday = thirdFriday(info.getYear(), info.getMonth());
        var days = ChronoUnit.DAYS.between(curDate, friday);
        return new Tuple2<>(iso8601(friday), days);
    }
}
