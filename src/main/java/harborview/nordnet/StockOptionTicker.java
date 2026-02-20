package harborview.nordnet;

import java.util.Objects;

public record StockOptionTicker(String value) {
    public StockOptionTicker(String value) {
        this.value = value;
        Objects.requireNonNull(value);
    }
}
