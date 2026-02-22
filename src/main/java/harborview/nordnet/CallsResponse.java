package harborview.nordnet;

import com.fasterxml.jackson.annotation.JsonGetter;
import harborview.nordnet.stockmarket.StockOptionDTO;
import harborview.nordnet.stockmarket.StockPriceDTO;

import java.util.List;

public record CallsResponse(@JsonGetter("stockprice") StockPriceDTO price,
                            @JsonGetter("opx") List<StockOptionDTO> options) {
}
