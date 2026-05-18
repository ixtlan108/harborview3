package harborview.api.maunaloa;

import harborview.nordnet.api.RLine;
import harborview.domain.stockmarket.StockTicker;
import harborview.dto.StatusDTO;
import harborview.rapanui.api.RapanuiCore;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/maunaloa/risclines")
public class RiscLineAPI {

    //private final MaunaloaCore maunaloaCore;
    private final RapanuiCore rapanuiCore;

    public RiscLineAPI(RapanuiCore rapanuiCore) {
        this.rapanuiCore = rapanuiCore;
    }

    //public List<RLine> riscLines(@PathVariable("ticker") String ticker) {
    @GetMapping(value = "/{ticker}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<RLine>> riscLines(@PathVariable("ticker") int ticker) {
        var stockTicker = new StockTicker(ticker);
        return ResponseEntity.ok(rapanuiCore.getRiscLines(stockTicker));
    }

    @DeleteMapping(value = "/{ticker}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<StatusDTO> deleteAllRiscLines(@PathVariable("ticker") int ticker) {
        var stockTicker = new StockTicker(ticker);
        return ResponseEntity.ok(rapanuiCore.deleteAllRiscLines(stockTicker));
    }

    @GetMapping(value = "/spot/{ticker}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> spot(@PathVariable("ticker") int ticker) {
        //var stockTicker = new StockTicker(ticker);
        //return ResponseEntity.ok(maunaloaCore.spot(stockTicker));
        return null;
    }
}
