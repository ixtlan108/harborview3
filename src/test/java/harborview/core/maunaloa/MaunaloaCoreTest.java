package harborview.core.maunaloa;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import harborview.domain.nordnet.NordnetRepository;
import harborview.domain.core.maunaloa.MaunaloaCore;
import harborview.domain.nordnet.*;
import harborview.domain.stockmarket.StockOptionTicker;
import harborview.domain.stockmarket.StockTicker;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import vega.financial.calculator.BlackScholes;
import vega.financial.calculator.OptionCalculator;
import static vega.financial.StockOptionType.CALL;

import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.matches;
import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.offset;

@SpringBootTest
//@ActiveProfiles("test")
public class MaunaloaCoreTest {

    private final StockOptionTicker realTicker = new StockOptionTicker("YAR3A528.02X");
    private final StockOptionTicker fakeTicker = new StockOptionTicker("YAR1A400");

    private final StockTicker ticker = new StockTicker(3);
    private final OptionCalculator calculaotor = new BlackScholes();

    @MockBean
    NordnetRepository nordnetAdapter;

    MaunaloaCore maunaloaCore;

    @BeforeEach
    public void init() {
        maunaloaCore = new MaunaloaCore(nordnetAdapter, null, null, calculaotor);
        //when(nordnetAdapter.equals(2)).thenReturn(true);
    }

    @Test
    public void test_parse_find_option_json() {

        String testJson = "{\"stock-price\":{\"h\":458.9,\"l\":450.6,\"c\":452.6,\"o\":452.0,\"unix-time\":1685113860000}," +
                            "\"option\":{\"expiry\":\"2023-01-20\",\"ticker\":\"YAR3A528.02X\"," +
                            "\"days\":117,\"ivSell\":0.1375,\"sell\":2.6,\"buy\":1.8,\"ivBuy\":0.10,\"ot\":1,\"x\":528.02}}";

        try {
            FindOptionResponse bean = new ObjectMapper()
                    .readerFor(FindOptionResponse.class)
                    .readValue(testJson);

            assertThat(bean.getStockPrice()).isNotNull();
            assertThat(bean.getStockPrice().getOpen()).isEqualTo(452.0, offset(0.1));
            assertThat(bean.getStockPrice().getHi()).isEqualTo(458.9, offset(0.1));
            assertThat(bean.getStockPrice().getLo()).isEqualTo(450.6, offset(0.1));
            assertThat(bean.getStockPrice().getClose()).isEqualTo(452.6, offset(0.1));
            assertThat(bean.getStockPrice().getUnixTime()).isEqualTo(1685113860000L);
            assertThat(bean.getStockOption()).isNotNull();
            assertThat(bean.getStockOption().getTicker()).isEqualTo(realTicker.ticker());
            assertThat(bean.getStockOption().getExpiry()).isEqualTo("2023-01-20");
            assertThat(bean.getStockOption().getDays()).isEqualTo(117);
            assertThat(bean.getStockOption().getOptionType()).isEqualTo(CALL);
            assertThat(bean.getStockOption().getIvBid()).isEqualTo(0.1, offset(0.01));
            assertThat(bean.getStockOption().getBid()).isEqualTo(1.8, offset(0.1));
            assertThat(bean.getStockOption().getIvAsk()).isEqualTo(0.1375, offset(0.0001));
            assertThat(bean.getStockOption().getAsk()).isEqualTo(2.6, offset(0.1));
            assertThat(bean.getStockOption().getX()).isEqualTo(528.02, offset(0.01));

        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }


    @Test
    void test_calc_risc_stock_prices_option_not_found() {
        when(nordnetAdapter.findOption(fakeTicker)).thenReturn(null);
        var risc = new RiscRequest(fakeTicker, 2.25);
        var riscs = Collections.singletonList(risc);
        var actual = maunaloaCore.calcRiscStockPrices(riscs);
        assertThat(actual.size()).isEqualTo(1);
        var response = actual.get(0);
        assertThat(response.status()).isEqualTo(RiscResponseStatus.COULD_NOT_FIND_OPTION_ERROR);
    }

    @Test
    void test_calc_risc_stock_prices_option_found() {
        when(nordnetAdapter.findOption(realTicker)).thenReturn(createResponse());
        assertThat(maunaloaCore.getRiscLines(ticker).size()).isEqualTo(0);
        var risc = new RiscRequest(realTicker, 2.25);
        var riscs = Collections.singletonList(risc);
        var actual = maunaloaCore.calcRiscStockPrices(riscs);
        assertThat(actual.size()).isEqualTo(1);
        var response = actual.get(0);
        assertThat(response.status()).isEqualTo(RiscResponseStatus.OK);

        var riscLines = maunaloaCore.getRiscLines(ticker);
        assertThat(riscLines.size()).isEqualTo(1);

    }


    FindOptionResponse createResponse() {
        var result = new FindOptionResponse();

        var stockOption = new StockOption("YAR3L440", "2023-12-15", 28.27, 0.25,
                22.1, 0.20,440.0, 196, 1);
        // brEven = 437.27
        var stockPrice = new StockPrice(416.19, 423.5, 416, 422.6, 1702594800000L);

        result.setStockOption(stockOption);
        result.setStockPrice(stockPrice);

        return result;
    }

}
