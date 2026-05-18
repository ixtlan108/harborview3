package harborview.rapanui;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import harborview.domain.core.Core;
import harborview.domain.error.ApplicationError;
import harborview.domain.functional.Either;
import harborview.domain.stockmarket.StockTicker;
import harborview.dto.StatusCode;
import harborview.dto.StatusDTO;
import harborview.nordnet.api.RLine;
import harborview.nordnet.api.RiscRequest;
import harborview.nordnet.api.RiscResponse;
import harborview.nordnet.api.RiscResponseStatus;
import harborview.nordnet.repository.NordnetRepository;
import harborview.nordnet.util.StockOptionUtil;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import vega.exception.BinarySearchException;
import vega.financial.calculator.OptionCalculator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

@Component
public class RapanuiCore {

    private final Core core;
    private final NordnetRepository nordnetRepository;
    private final OptionCalculator calculator;

    Cache<Integer, List<RLine>> rlineCache = Caffeine.newBuilder()
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .build();


    public RapanuiCore(@Qualifier("adapter.demo") NordnetRepository nordnetRepository,
                       Core core,
                @Qualifier("blackScholes") OptionCalculator calculator) {
        this.core = core;
        this.nordnetRepository = nordnetRepository;
        this.calculator = calculator;
    }

    public Either<ApplicationError, List<RiscResponse>> calcRiscStockPrices(List<RiscRequest> request) {
        return core.handleSearch(() -> {
            var result = new ArrayList<RiscResponse>();
            for (var risc : request) {
                result.add(calcRiscStockPrice(risc));
            }
            return result;
        });
    }

    RiscResponse calcRiscStockPrice(RiscRequest request) {

        //*
        var info = StockOptionUtil.stockOptionInfoFromTicker(request.getTicker());

        var oid = info.getStockTicker().oid(); //info.first();

        var optionType = info.getStockOptionType(); //info.third();

        var hit = nordnetRepository.findOption(request.getTicker());

        if (hit == null) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.COULD_NOT_FIND_OPTION_ERROR);
        }

        var option = hit.second();

        var riscAdjustedPrice = option.getAsk() - request.getRiscValue();

        if (riscAdjustedPrice < 0) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.RISC_ADJUSTED_PRICE_LESS_THAN_ZERO);
        }

        if (option.getIvBid() < 0) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.IV_LESS_THAN_ZERO);
        }

        double curStockPrice = 0.0;
        double curBreakEven = 0.0;
        var stockPrice = hit.first();
        try {
            curStockPrice = calculator.stockPriceFor2(optionType,
                    riscAdjustedPrice,
                    option.getX(),
                    option.getDays(),
                    option.getIvBid(),
                    stockPrice.cls());
        } catch (BinarySearchException ex) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.CALCULATE_OPTION_PRICE_ERROR);
        }

        try {
            curBreakEven = calculator.stockPriceFor2(optionType,
                    option.getAsk(),
                    option.getX(),
                    option.getDays(),
                    option.getIvBid(),
                    stockPrice.cls());
        } catch (BinarySearchException ex) {
            return new RiscResponse(request.getTicker(), -1.0, RiscResponseStatus.BREAK_EVEN_ERROR);
        }

        var result = new RiscResponse(request.getTicker(), curStockPrice, RiscResponseStatus.OK);

        saveRiscResult(oid,
                request.getTicker().value(),
                option.getBid(),
                option.getAsk(),
                request.getRiscValue(),
                curStockPrice,
                riscAdjustedPrice,
                curBreakEven);

        return result;

        //*/
    }

    //----------------------------- Risc Lines --------------------------------
    void saveRiscResult(int oid,
                        String ticker,
                        double bid,
                        double ask,
                        double riscValue,
                        double riscStockPrice,
                        double riscOptionPrice,
                        double breakEven) {
        var line = new RLine(oid, ticker, bid, ask, riscValue, riscStockPrice, riscOptionPrice, breakEven);

        var lines = rlineCache.getIfPresent(oid);
        if (lines == null)  {
            //logger.info(String.format("Empty rline cache for oid: %d", oid));
            var newLines = new ArrayList<RLine>();
            newLines.add(line);
            rlineCache.put(oid, newLines);
        }
        else {
            //logger.info(String.format("Found rline cache for oid: %d", oid));
            lines.add(line);
        }
    }

    public List<RLine> getRiscLines(StockTicker ticker) {
        var lines = rlineCache.getIfPresent(ticker.oid());
        return Objects.requireNonNullElse(lines, Collections.emptyList());
    }
    public StatusDTO deleteAllRiscLines(StockTicker ticker) {
        rlineCache.invalidate(ticker.oid());
        return new StatusDTO(true, String.format("Deleted risc lines for %s ok", ticker.ticker()), StatusCode.OK.getStatus());
    }
    public void invalidateRiscLineCache() {
        rlineCache.invalidateAll();
    }


}
