package harborview.nordnet;

import harborview.domain.core.Core;
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
    private final Core core;

    public NordnetCore(@Qualifier("adapter.demo") NordnetRepository repos,
                       Core core) {
    //public NordnetCore(NordnetRepository repos) {
        this.repos = repos;
        this.core = core;
        System.out.println("NordnetCore: " + repos);
    }

    public Either<ApplicationError, StockPrice> getStockPrice(StockTicker ticker) {
        return core.handle(() -> repos.getStockPrice(ticker));
    }

    public Either<ApplicationError, List<StockOption>> getCalls(StockTicker ticker) {
        return core.handle(() -> repos.getCalls(ticker));
    }

    public Either<ApplicationError,List<StockOption>> getPuts(StockTicker ticker) {
        return core.handle(() -> repos.getPuts(ticker));
    }

    public void resetCaffeine() {
        repos.resetCaffeine();
    }

}
