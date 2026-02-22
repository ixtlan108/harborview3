package harborview.nordnet.repository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class NordnetAdapterV1RealTest {

    @Autowired
    NordnetAdapterV1 nordnetAdapter;

    @Test
    void test_parse_real_time() {
        var calls = nordnetAdapter.getCalls(null);
        System.out.println(calls);
    }
}
