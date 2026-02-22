package harborview.nordnet.repository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class NordnetAdapterV1FileSystemTest {


    @Autowired
    NordnetAdapterV1FileSystem nordnetAdapter;

    @Test
    void test_parse_filesystem() {
        var calls = nordnetAdapter.getCalls(null);
        System.out.println(calls);
    }
}
