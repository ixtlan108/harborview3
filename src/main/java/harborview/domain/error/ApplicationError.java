package harborview.domain.error;

public sealed interface ApplicationError
        permits GeneralError, SqlError {
}
