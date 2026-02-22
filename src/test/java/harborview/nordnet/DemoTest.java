package harborview.nordnet;

import harborview.nordnet.repository.NordnetAdapterV1;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class DemoTest {
    @Autowired
    NordnetAdapterV1 nordnetAdapterV1;
}
