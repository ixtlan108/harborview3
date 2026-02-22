package harborview.nordnet;

import harborview.api.util.ApiUtil;
import harborview.domain.error.ApplicationError;
import harborview.domain.functional.Either;
import harborview.nordnet.repository.NordnetRepository;
import harborview.nordnet.stockmarket.StockOption;
import harborview.nordnet.stockmarket.StockPrice;
import harborview.nordnet.stockmarket.StockTicker;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class NordnetCore {

    private final NordnetRepository repos;

    public NordnetCore(@Qualifier("v1") NordnetRepository repos) {
        this.repos = repos;
    }
    public Either<ApplicationError, StockPrice> getStockPrice(StockTicker ticker) {
        return ApiUtil.handle(() -> repos.getStockPrice(ticker));
    }
    public Either<ApplicationError, List<StockOption>> getCalls(StockTicker ticker) {
        return ApiUtil.handle(() -> repos.getCalls(ticker));
    }
    public Either<ApplicationError,List<StockOption>> getPuts(StockTicker ticker) {
        return ApiUtil.handle(() -> repos.getPuts(ticker));
    }
    public void resetCaffeine() {
        repos.resetCaffeine();
    }

}
