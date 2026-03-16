package harborview.transform.maunaloa;

import harborview.domain.stockmarket.StockMarketService;
import harborview.domain.stockmarket.StockOption;
import harborview.domain.stockmarket.StockOptionPurchase;
import harborview.domain.stockmarket.request.PurchaseOptionRequest;
import harborview.domain.stockmarket.request.RegpurRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import vega.financial.StockOptionType;

import java.time.LocalDate;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.offset;

@SpringBootTest
public class RequestTransformTest {

    private final String ticker = "YAR4F480";

    @MockBean
    StockMarketService stockMarketAdapter;

    RequestTransform requestTransform;

    @BeforeEach
    public void init() {
        requestTransform = new RequestTransform(stockMarketAdapter);
    }

    @Test
    void test_transform_purchase_option_able() {
        when(stockMarketAdapter.findStockOption(any())).thenReturn(createStockOption());
        StockOptionPurchase purchase = requestTransform.mapPurchaseOptionRequest(createPurchaseOptionRequest());
        assertThat(purchase).isNotNull();
        assertThat(purchase.getBuyAtPurchase()).isEqualTo(11.0, offset(0.1));
        assertThat(purchase.getPrice()).isEqualTo(12.0, offset(0.1));
        assertThat(purchase.getVolume()).isEqualTo(10L);
        assertThat(purchase.getSpotAtPurchase()).isEqualTo(369.0, offset(0.1));
    }

    @Test
    void test_transform_reg_pur_request() {
        when(stockMarketAdapter.findStockOption(any())).thenReturn(createStockOption());
        var purchase = requestTransform.mapRegPurRequest(createRegpurRequest());
        assertThat(purchase).isNotNull();
        assertThat(purchase.first()).isNotNull();
        assertThat(purchase.second()).isNotNull();

        StockOption option = purchase.first();
        assertThat(option.getTicker()).isEqualTo(ticker);
        assertThat(option.getX()).isEqualTo(480.0, offset(0.1));
        assertThat(option.getExpiry()).isEqualTo(LocalDate.of(2024,6,21));
        assertThat(option.getOpType()).isEqualTo(StockOptionType.CALL);
        assertThat(option.getStockId()).isEqualTo(3);
        assertThat(option.getSeries()).isEqualTo("4F");
    }

    StockOption createStockOption() {
        var option = new StockOption();

        option.setTicker(ticker);
        option.setOpType(StockOptionType.CALL);
        option.setX(480.0);
        option.setStockId(3);
        return option;
    }
    PurchaseOptionRequest createPurchaseOptionRequest() {
        return new PurchaseOptionRequest(ticker, 12.0, 11.0, 10, 369.0, false);
    }
    RegpurRequest createRegpurRequest() {
        return new RegpurRequest(ticker, 12.0, 11.0, 10, 369.0, false, 3,
                StockOptionType.CALL.getValue(),
                "2024-06-21", 480.0);
    }
}
