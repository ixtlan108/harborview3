package harborview.api.util;

import harborview.api.response.AppStatusCode;
import harborview.api.response.DefaultResponse;
import harborview.api.response.PayloadResponse;
import harborview.domain.error.ApplicationError;
import harborview.domain.functional.Either;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;

import java.util.function.Function;

public class ApiUtil {
    public static <T> ResponseEntity<DefaultResponse> map(ApplicationError error, String msg) {
        if (error != null) {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new DefaultResponse(error.getStatus(),error.getMsg()));
        }
        else {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new DefaultResponse(1, msg));
        }
    }

    public static <T> ResponseEntity<PayloadResponse<T>> map(@NonNull Either<ApplicationError,T> result) {
        return mapWithDefault(result, null);
    }
    public static <Q,T> ResponseEntity<PayloadResponse<T>>
        mapWithFn(@NonNull Either<ApplicationError,Q> result, Function<Q,T> fn) {
        return mapWithErrFn(result,fn,null);
    }
    public static <Q,T> ResponseEntity<PayloadResponse<T>> mapWithErrFn(@NonNull Either<ApplicationError,Q> result,
                                                                        Function<Q,T> fn,
                                                                        T inCaseOfError) {
        if (result.isRight()) {
            var result1 = fn.apply(result.getRight());
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new PayloadResponse<T>(result1, AppStatusCode.OK.getStatusCode(), null));
        }
        else {
            var err = result.getLeft();
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new PayloadResponse<T>(inCaseOfError, err.getStatus(), err.getMsg()));
        }
    }
    public static <T> ResponseEntity<PayloadResponse<T>> mapWithDefault(@NonNull Either<ApplicationError,T> result, T inCaseOfError) {
        if (result.isRight()) {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new PayloadResponse<T>(result.getRight(), AppStatusCode.OK.getStatusCode(), null));
        }
        else {
            return mapAppError(result.getLeft(), inCaseOfError);
        }
    }
    public static <T> ResponseEntity<PayloadResponse<T>> mapAppError(@NonNull ApplicationError appError, T inCaseOfError) {
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(new PayloadResponse<T>(inCaseOfError, appError.getStatus(), appError.getMsg()));
    }
}
