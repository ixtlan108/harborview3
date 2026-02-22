package harborview.domain.stockmarket.request;

import java.util.Objects;

public class PurchaseOptionValidation {
    public static void validate(PurchaseOptionAble purchase) {
        Objects.requireNonNull(purchase.ticker());
        /*
        if (purchase.ask() <= 0) {
            throw new RuntimeException("ask must be greater than zero");
        }
        if (purchase.bid() <= 0) {
            throw new RuntimeException("bid must be greater than zero");
        }

         */
        if (purchase.volume() < 0) {
            throw new RuntimeException("volume must be greater than zero");
        }
        /*
        if (purchase.spot() <= 0) {
            throw new RuntimeException("spot must be greater than zero");
        }
        if (purchase.ask() < purchase.bid()) {
            throw new RuntimeException("ask must be greater than bid");
        }

         */
    }
}
