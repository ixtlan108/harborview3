package harborview.controller.maunaloa;

/*
import com.fasterxml.jackson.databind.ObjectMapper;
import harborview.api.maunaloa.StockOptionAPI;
import harborview.controller.ControllerTestBase;
import harborview.domain.nordnet.FindOptionResponse;
import harborview.domain.stockmarket.*;
import harborview.domain.stockmarket.request.PurchaseOptionRequest;
import harborview.domain.stockmarket.request.RegpurRequest;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;

import static harborview.dto.StatusCode.OK;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import vega.financial.StockOptionType;

 */


//@WebMvcTest(StockOptionAPI.class)
//public class StockOptionControllerTest extends ControllerTestBase {
public class StockOptionControllerTest {
    /*
    private static ObjectMapper mapper = new ObjectMapper();

    @Test
    void test_purchase_with_option_in_database() {
        try {
            var request = createRequestHasOptionInDatabase();
            String jsonRequest = mapper.writeValueAsString(request);
            when(stockMarketAdapter.findStockOption(new StockOptionTicker(request.ticker()))).thenReturn(createStockOption());
            doNothing().when(stockMarketAdapter).insertPurchase(any(), any());
            this.mockMvc.perform(
                            MockMvcRequestBuilders.post("/maunaloa/stockoption/purchase")
                            .contentType(APPLICATION_JSON)
                            .content(jsonRequest)
                            .accept(APPLICATION_JSON))
                    .andDo(MockMvcResultHandlers.print())
                    .andExpect(MockMvcResultMatchers.status().isOk())
                    .andExpect(MockMvcResultMatchers.jsonPath("$.statusCode").value(OK.getStatus()));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Test
    void test_purchase_with_option_not_in_database() {
        try {
            var request = createRequestOptionDoesNotExistInDatabase();
            String jsonRequest = mapper.writeValueAsString(request);
            when(stockMarketAdapter.findStockOption(new StockOptionTicker(request.ticker()))).thenReturn(createStockOption());
            doNothing().when(stockMarketAdapter).insertPurchase(any(), any());
            this.mockMvc.perform(
                            MockMvcRequestBuilders.post("/maunaloa/stockoption/purchase")
                                    .contentType(APPLICATION_JSON)
                                    .content(jsonRequest)
                                    .accept(APPLICATION_JSON))
                    .andDo(MockMvcResultHandlers.print())
                    .andExpect(MockMvcResultMatchers.status().isOk())
                    .andExpect(MockMvcResultMatchers.jsonPath("$.statusCode").value(OK.getStatus()));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    @Test
    void test_register_and_purchase() {
        try {
            var request = createRegpurRequest();
            String jsonRequest = mapper.writeValueAsString(request);
            when(stockMarketAdapter.findStockOption(new StockOptionTicker(request.ticker()))).thenReturn(null);
            doNothing().when(stockMarketAdapter).insertPurchase(any(), any());
            this.mockMvc.perform(
                            MockMvcRequestBuilders.post("/maunaloa/stockoption/regpur")
                                    .contentType(APPLICATION_JSON)
                                    .content(jsonRequest)
                                    .accept(APPLICATION_JSON))
                    .andDo(MockMvcResultHandlers.print())
                    .andExpect(MockMvcResultMatchers.status().isOk())
                    .andExpect(MockMvcResultMatchers.jsonPath("$.statusCode").value(OK.getStatus()));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    StockOption createStockOption() {
        var result = new StockOption();

        result.setOid(99);

        return result;
    }
    FindOptionResponse createFindOptionResponse() {
        var result = new FindOptionResponse();

        return result;
    }

    RegpurRequest createRegpurRequest() {
        return new RegpurRequest("YAR4F480", 12.0, 11.0, 10, 369.0, false, 3,
                StockOptionType.CALL.getValue(),
                "2024-06-21", 480.0);
    }

    PurchaseOptionRequest createRequestHasOptionInDatabase() {
        return new PurchaseOptionRequest("VALID", 12.0, 11.0, 10, 450.0, false);
    }
    PurchaseOptionRequest createRequestOptionDoesNotExistInDatabase() {
        return new PurchaseOptionRequest("INVALID", 12.0, 11.0, 10, 450.0, false);
    }

     */
}
