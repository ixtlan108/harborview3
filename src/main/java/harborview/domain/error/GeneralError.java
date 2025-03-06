package harborview.domain.error;

public sealed interface GeneralError extends ApplicationError {
    record GeneralApplicationError(String msg) implements GeneralError {}
}
