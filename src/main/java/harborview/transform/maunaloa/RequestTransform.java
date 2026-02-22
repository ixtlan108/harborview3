package harborview.transform.maunaloa;

import harborview.domain.stockmarket.StockMarketService;
import harborview.domain.stockmarket.*;
import harborview.domain.stockmarket.request.PurchaseOptionAble;
import harborview.domain.stockmarket.request.RegpurRequest;
import oahu.dto.Tuple2;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class RequestTransform {
    private final StockMarketService stockMarketAdapter;

    public RequestTransform(StockMarketService stockMarketAdapter) {
        this.stockMarketAdapter = stockMarketAdapter;
    }

    private int mapRt(boolean rt) {
        return rt ? 4 : 11;
    }
    public StockOptionPurchase mapPurchaseOptionRequest(PurchaseOptionAble request)  {
        if (request == null) {
            return null;
        }
        var option = stockMarketAdapter.findStockOption(new StockOptionTicker(request.ticker()));
        if (option == null) {
            return null;
        }
        return createStockOptionPurchase(request, option);
    }

    public Tuple2<StockOption,StockOptionPurchase> mapRegPurRequest(RegpurRequest request)  {

        var option = new StockOption();

        option.setTicker(request.ticker());
        option.setOpTypeStr(request.opType());
        option.setX(request.x());
        option.setStockId(request.stockId());

        var stockOption = createStockOptionPurchase(request,option);

        return new Tuple2<>(option,stockOption);
    }

    private StockOptionPurchase createStockOptionPurchase(PurchaseOptionAble request, StockOption option) {
        var result = new StockOptionPurchase();

        result.setSpotAtPurchase(request.spot());
        result.setBuyAtPurchase(request.bid());
        result.setPrice(request.ask());
        result.setVolume(request.volume());
        result.setLocalDx(LocalDate.now());
        result.setOptionId(option.getOid());
        result.setPurchaseType(mapRt(request.rt()));
        result.setStatus(1);

        return result;
    }

}
