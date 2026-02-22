package harborview.api.maunaloa;

import harborview.api.response.DefaultResponse;
import harborview.api.response.stockmarket.StockOptionPurchaseResponse;
import harborview.api.transform.stockmarket.ResponseTransform;
import harborview.api.util.ApiUtil;
import harborview.domain.core.maunaloa.MaunaloaCore;
import harborview.domain.stockmarket.request.PurchaseOptionRequest;
import harborview.domain.stockmarket.request.RegpurRequest;
import harborview.domain.stockmarket.StockOptionTicker;
import harborview.domain.stockmarket.StockTicker;
import harborview.dto.StatusDTO;
import harborview.dto.ValueDTO;
import harborview.transform.maunaloa.RequestTransform;
import harborview.util.StockOptionUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import java.util.List;

import static harborview.dto.StatusCode.*;

@Controller
@RequestMapping("/maunaloa/stockoption")
public class StockOptionAPI {

    private final Logger logger = LoggerFactory.getLogger(StockOptionAPI.class);

    private final MaunaloaCore maunaloaCore;
    private final RequestTransform requestTransform;
    private final ResponseTransform responseTransform;

    public StockOptionAPI(MaunaloaCore maunaloaCore,
                          RequestTransform requestTransform,
                          ResponseTransform responseTransform) {
        this.maunaloaCore = maunaloaCore;
        this.requestTransform = requestTransform;
        this.responseTransform = responseTransform;
    }

    @GetMapping(value = "/calls/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> calls(@PathVariable("oid") int oid) {
        //return ResponseEntity.ok(maunaloaCore.calls(new StockTicker(oid)));
        return null;
    }

    @GetMapping(value = "/puts/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> puts(@PathVariable("oid") int oid) {
        //return ResponseEntity.ok(maunaloaCore.puts(new StockTicker(oid)));

        return null;
    }

    @GetMapping(value = "/price/{ticker}/{stockPrice}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ValueDTO<Double>> calcOptionPrice(@PathVariable("ticker") String ticker, @PathVariable("stockPrice") double stockPrice) {
        var price = maunaloaCore.optionPriceFor(new StockOptionTicker(ticker), stockPrice);
        return ResponseEntity.ok(new ValueDTO<>(price));
    }

    @GetMapping(value = "/purchases/{purchaseType}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<StockOptionPurchaseResponse>> fetchOptionPurchases(@PathVariable("purchaseType") int purchaseType) {
        var purchases = maunaloaCore.stockOptionPurchases(purchaseType, 1, null);
        var response = responseTransform.mapStockOptionPurchases(purchases);
        return ResponseEntity.ok(response);
    }


    @PostMapping(value = "/purchase", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<DefaultResponse> purchaseOption(@RequestBody PurchaseOptionRequest request) {
        var ticker = new StockOptionTicker(request.ticker());
        var result = maunaloaCore.purchaseOption(ticker,request.volume());
        return ApiUtil.map(result, "Purchase ok");
    }

    @PostMapping(value = "/regpur", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<StatusDTO> registerPurchasedOption(@RequestBody RegpurRequest request) {
        logger.info(String.format("Registering and purchasing option, ticker: %s", request.ticker()));
        try {
            request.validate();
        }
        catch (Exception ex) {
            logger.error(String.format("Request validation error, ticker: %s", request.ticker()));
            return ResponseEntity.ok(new StatusDTO(false, ex.getMessage(), REQUEST_VALIDATION_ERROR.getStatus()));
        }

        var purchase = requestTransform.mapRegPurRequest(request);

        if (purchase.first() == null || purchase.second() == null) {
            return ResponseEntity.ok(new StatusDTO(false, "Could not transform RegpurRequest", ERROR.getStatus()));
        }

        return ResponseEntity.ok(maunaloaCore.registerAndPurchaseOption(purchase));
    }

    @PostMapping(value = "/sell", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<StatusDTO> sellOption() {

        return ResponseEntity.ok(new StatusDTO(true, "demo", OK.getStatus()));
    }

    /*
    @ResponseBody
    @GetMapping(value = "/demo", produces = MediaType.APPLICATION_JSON_VALUE)
    public StatusDTO demo() {
        maunaloaCore.demo();
        return new StatusDTO(true, "demo", OK.getStatus());
    }
     */

}
