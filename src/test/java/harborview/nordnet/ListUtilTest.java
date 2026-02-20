package harborview.nordnet;

import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class ListUtilTest {

    @Test
    void test_join_lists() {
        List<Integer> l1 = Arrays.asList(1,2,3);
        List<Integer> l2 = Arrays.asList(21,22,23);
        List<Integer> l3 = Arrays.asList(31,32,33);

        List<List<Integer>> all = Arrays.asList(l1,l2,l3);
        var result = ListUtil.joinLists(all);
        assertEquals(9, result.size());

        assertTrue(result.containsAll(Arrays.asList(1,2,3,21,22,23,31,32,33)));

        List<Integer> initialList = Arrays.asList(41,42,43);

        var result2 = ListUtil.joinLists(initialList, all);
        assertEquals(12, result2.size());
        assertTrue(result2.containsAll(Arrays.asList(1,2,3,21,22,23,31,32,33,41,42,43)));
    }

}
