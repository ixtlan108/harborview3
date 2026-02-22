package harborview.nordnet.util;

import java.util.ArrayList;
import java.util.List;

public class ListUtil {

    public static <T> List<T> joinLists(List<List<T>> lists) {
        var count = 0;
        for (List<T> l : lists) {
            count += l.size();
        }
        var result = new ArrayList<T>(count);

        for (List<T> l : lists) {
            result.addAll(l);
        }
        return result;
    }

    public static <T> List<T> joinLists(List<T> initialList, List<List<T>> lists) {
        var count = 0;
        for (List<T> l : lists) {
            count += l.size();
        }
        count += initialList.size();

        var result = new ArrayList<T>(count);

        result.addAll(initialList);
        for (List<T> l : lists) {
            result.addAll(l);
        }
        return result;
    }
    //return Stream.of(lists).flatMap(Collection::stream).toList();
}
