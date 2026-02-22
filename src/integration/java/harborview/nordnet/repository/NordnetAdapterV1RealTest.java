package harborview.nordnet.repository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class NordnetAdapterV1RealTest {

    @Autowired
    @Qualifier("adapter.nordnet")
    NordnetAdapterV1 nordnetAdapter;

    @Test
    void test_parse_real_time() {
    }
}
