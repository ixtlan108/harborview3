package harborview.nordnet.api;

import com.fasterxml.jackson.annotation.JsonGetter;
import harborview.nordnet.stockmarket.StockOptionDTO;
import harborview.nordnet.stockmarket.StockPriceDTO;

import java.util.List;

public record DerivativesResponse(@JsonGetter("stockprice") StockPriceDTO price,
                                  @JsonGetter("opx") List<StockOptionDTO> options) {
}
