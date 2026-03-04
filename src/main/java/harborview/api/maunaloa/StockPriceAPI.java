package harborview.api.maunaloa;

import harborview.api.maunaloa.response.SpotResponse;
import harborview.api.response.PayloadResponse;
import harborview.api.util.ApiUtil;
import harborview.domain.core.maunaloa.MaunaloaCore;
import harborview.domain.stockmarket.StockTicker;
import harborview.dto.html.Charts;
import harborview.dto.html.SelectItem;
import harborview.nordnet.api.RiscRequest;
import harborview.nordnet.api.RiscResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;
import java.util.Collections;
import java.util.List;

@Controller
@RequestMapping("/maunaloa/stockprice")
public class StockPriceAPI {

    private final MaunaloaCore maunaloaCore;

    public StockPriceAPI(MaunaloaCore maunaloaCore) {
        this.maunaloaCore = maunaloaCore;
    }

    @GetMapping(value = "/spot/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<SpotResponse>> getSpot(@PathVariable int oid) {
        var sp = maunaloaCore.getSpot(new StockTicker(oid));
        return ApiUtil.mapWithFn(sp,
                r -> new SpotResponse(r.getOpn(),r.getHi(),r.getLo(),r.getCls(),r.getUnixTime()));
    }

    @GetMapping(value = "/tickers", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<List<SelectItem>>> tickers() {
        return ApiUtil.mapWithDefault(maunaloaCore.getStockTickers(), Collections.emptyList());
    }

    @GetMapping(value = "/days/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<Charts>> days(@PathVariable int oid) {
        return ApiUtil.map(maunaloaCore.days(new StockTicker(oid)));
    }

    @GetMapping(value = "/weeks/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<Charts>> weeks(@PathVariable int oid) {
        return ApiUtil.map(maunaloaCore.weeks(new StockTicker(oid)));
    }

    @GetMapping(value = "/months/{oid}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<Charts>> months(@PathVariable int oid) {
        return ApiUtil.map(maunaloaCore.months(new StockTicker(oid)));
    }

    @PutMapping(value = "/calculate", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<PayloadResponse<List<RiscResponse>>> calcRiscStockPrices(@RequestBody List<RiscRequest> riscs) {
        return ApiUtil.map(maunaloaCore.calcRiscStockPrices(riscs));
    }

}
