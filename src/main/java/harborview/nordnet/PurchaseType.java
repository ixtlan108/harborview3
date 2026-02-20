package harborview.nordnet;

public enum PurchaseType {
    PAPER(11),
    REAL_TIME(4);

    private final int value;

    PurchaseType (int value) {
        this.value = value;
    }

    public static PurchaseType fromInt(int val) {
        return switch (val) {
            case 4 -> REAL_TIME;
            case 11 -> PAPER;
            default -> null;
        };
    }

    public int getValue() {
        return value;
    }
}
