package harborview.api.util;

import harborview.api.response.AppStatusCode;
import harborview.api.response.DefaultResponse;
import harborview.api.response.PayloadResponse;
import harborview.domain.error.ApplicationError;
import harborview.domain.error.GeneralError;
import harborview.domain.error.SqlError;
import harborview.domain.functional.Either;
import org.mybatis.spring.MyBatisSystemException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;

import java.util.function.Function;
import java.util.function.Supplier;

public class ApiUtil {
    public static <T> ResponseEntity<DefaultResponse> map(@NonNull ApplicationError error, String msg) {
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
                    .body(new PayloadResponse<T>(result1, AppStatusCode.OK, null));
        }
        else {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new PayloadResponse<T>(inCaseOfError, appErrToAppStatusCode(result.getLeft()), mapErr2str(result.getLeft())));
        }
    }
    public static <T> ResponseEntity<PayloadResponse<T>> mapWithDefault(@NonNull Either<ApplicationError,T> result, T inCaseOfError) {
        if (result.isRight()) {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new PayloadResponse<T>(result.getRight(), AppStatusCode.OK, null));
        }
        else {
            return mapAppError(result.getLeft(), inCaseOfError);
        }
    }
    public static <T> ResponseEntity<PayloadResponse<T>> mapAppError(@NonNull ApplicationError appError, T inCaseOfError) {
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(new PayloadResponse<T>(inCaseOfError, AppStatusCode.GENERAL_ERROR, mapErr2str(appError)));
    }
    public static String mapErr2str(ApplicationError err) {
        return switch (err) {
            case SqlError.DuplicateKeyError e -> "DuplicateKeyError: " + e.msg();
            case SqlError.GeneralSqlError e -> "GeneralSqlError: " + e.msg();
            case SqlError.MybatisSqlError e -> "MybatisSqlError: " + e.msg();
            case GeneralError.GeneralApplicationError e -> "GeneralApplicationError: " + e.msg();
        };
    }
    public static AppStatusCode appErrToAppStatusCode(ApplicationError err) {
        return switch (err) {
            case SqlError.DuplicateKeyError e -> AppStatusCode.DUPLICATE_KEY_ERROR;
            case SqlError.GeneralSqlError e -> AppStatusCode.GENERAL_SQL_ERROR;
            case SqlError.MybatisSqlError e -> AppStatusCode.MYBATIS_SQL_ERROR;
            case GeneralError.GeneralApplicationError e -> AppStatusCode.GENERAL_ERROR;
        };
    }
    /*
    public static DefaultResponse mapError(ApplicationError err) {
        return switch (err) {
            case SqlError.DuplicateKeyError e -> new DefaultResponse(AppStatusCode.DUPLICATE_KEY_ERROR, mapErr2str(err));
            case SqlError.GeneralSqlError e -> new DefaultResponse(AppStatusCode.GENERAL_SQL_ERROR, mapErr2str(err));
            case SqlError.MybatisSqlError e -> new DefaultResponse(AppStatusCode.MYBATIS_SQL_ERROR, mapErr2str(err));
            case GeneralError.GeneralApplicationError e -> new DefaultResponse(AppStatusCode.GENERAL_ERROR, mapErr2str(err));
        };
    }

     */
}
