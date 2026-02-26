package harborview.nordnet;

import harborview.api.response.PayloadResponse;
import harborview.api.util.ApiUtil;
import harborview.domain.functional.Either;
import harborview.nordnet.stockmarket.StockOption;
import harborview.nordnet.stockmarket.StockOptionDTO;
import harborview.nordnet.stockmarket.StockPriceDTO;
import harborview.nordnet.stockmarket.StockTicker;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/nordnet")
public class NordnetAPI {
    private final NordnetCore core;

    public NordnetAPI(NordnetCore core) {
        this.core = core;
    }

    @GetMapping(value = "/spot/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<StockPriceDTO>> spot(@PathVariable int oid) {
        var ticker = new StockTicker(oid);
        var price = core.getStockPrice(ticker);
        return ApiUtil.mapWithFn(price, StockPriceDTO::new);
    }


    @GetMapping(value = "/calls/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<CallsResponse>> calls(@PathVariable int oid) {
        var ticker = new StockTicker(oid);
        var result= core.getStockPrice(ticker).andThen(stockPrice ->
                core.getCalls(ticker).andThen(
                        opx -> Either.right(new CallsResponse(new StockPriceDTO(stockPrice), map(opx)))));
        return ApiUtil.map(result);
    }

    @GetMapping(value = "/puts/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<CallsResponse>> puts(@PathVariable int oid) {
        var ticker = new StockTicker(oid);
        var result= core.getStockPrice(ticker).andThen(stockPrice ->
                core.getPuts(ticker).andThen(
                        opx -> Either.right(new CallsResponse(new StockPriceDTO(stockPrice), map(opx)))));
        return ApiUtil.map(result);
    }

    @PutMapping(value = "/caffeine/reset")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void resetCaffeine() {
        core.resetCaffeine();
    }

    private List<StockOptionDTO> map(List<StockOption> options) {
        return options.stream().map(StockOptionDTO::new).toList();
    }

}
