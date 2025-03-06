package harborview.adapter;

import java.util.Map;

public class StockMarketAdapterUtil {
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
            //Map.entry(12, "PGS"),
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
            //Map.entry("PGS", 12),
            Map.entry("STB", 14),
            Map.entry("SUBC", 23),
            Map.entry("TEL", 6),
            Map.entry("TGS", 16),
            Map.entry("TOM", 17),
            Map.entry( "YAR", 3)
    );
    public static String mapOid(int value) {
        return oid2str.get(value);
    }
    public static int mapString(String value) {
        return str2oid.get(value);
    }
}
