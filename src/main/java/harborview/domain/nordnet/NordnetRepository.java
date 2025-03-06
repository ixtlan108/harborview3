package harborview.domain.nordnet;

import harborview.api.nordnet.response.FindOptionResponse;
import harborview.domain.stockmarket.StockOptionTicker;
import harborview.domain.stockmarket.StockTicker;

public interface NordnetRepository {
    FindOptionResponse findOption(StockOptionTicker ticker);
    String calls(StockTicker ticker);
    String puts(StockTicker ticker);
    String spot(StockTicker ticker);

}
