package harborview.controller;

import harborview.domain.stockmarket.StockMarketRepository;
import harborview.mybatis.MyBatisUtil;
import harborview.nordnet.repository.NordnetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest
public abstract class ControllerTestBase {

    @Autowired
    protected MockMvc mockMvc;

    @MockBean
    protected NordnetRepository nordnetAdapter;

    @MockBean
    protected StockMarketRepository stockMarketAdapter;

    @MockBean
    protected MyBatisUtil myBatisUtil;

}
