package harborview.domain.core.critter;

import harborview.domain.core.Core;
import harborview.domain.error.ApplicationError;
import harborview.domain.functional.Either;
import harborview.domain.stockmarket.StockMarketRepository;
import harborview.dto.critter.OptionPurchaseDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class CritterCore {
    private Logger logger = LoggerFactory.getLogger(CritterCore.class);

    private final StockMarketRepository stockMarketAdapter;
    private final Core core;

    public CritterCore(StockMarketRepository stockMarketAdapter,
                       Core core) {
        this.stockMarketAdapter = stockMarketAdapter;
        this.core = core;
    }

    public Either<ApplicationError,List<OptionPurchaseDTO>> activePurchasesWithCritters(int purchaseType) {
        return core.handleSearch(() -> {
            var purchases = stockMarketAdapter.activePurchasesWithCritters(purchaseType);
            if (purchases == null) {
                logger.warn(String.format("Empty list for critters, purchaseType=%d", purchaseType));
                return Collections.emptyList();
            }
            return purchases.stream().map(OptionPurchaseDTO::new).
                    collect(Collectors.toList());
        });
    }

    public void toggleRule(int ruleId, boolean active, boolean isAccRule) {
        stockMarketAdapter.toggleRule(ruleId, active, isAccRule);
    }
}
