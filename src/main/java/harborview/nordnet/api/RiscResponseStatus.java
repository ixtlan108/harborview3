package harborview.nordnet.api;

public enum RiscResponseStatus {
    OK(1),
    CALCULATE_OPTION_PRICE_ERROR(2),
    IV_LESS_THAN_ZERO(3),
    COULD_NOT_FIND_OPTION_ERROR(4),
    BREAK_EVEN_ERROR(5),
    RISC_ADJUSTED_PRICE_LESS_THAN_ZERO(6);
    private final int status;

    private RiscResponseStatus(int status) {
        this.status = status;
    }

    public int getStatus() {
        return status;
    }
}
