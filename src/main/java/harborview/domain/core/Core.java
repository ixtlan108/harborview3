package harborview.domain.core;

import harborview.domain.error.ApplicationError;
import harborview.domain.error.GeneralError;
import harborview.domain.error.SqlError;
import harborview.domain.functional.Either;
import org.mybatis.spring.MyBatisSystemException;
import org.springframework.dao.DuplicateKeyException;
import org.postgresql.util.PSQLException;
import org.springframework.stereotype.Component;

import java.util.function.Supplier;

@Component
public class Core {

    @FunctionalInterface
    public interface SaveCommand<T> {
        void handle() throws Exception;
    };

    public <T> ApplicationError handleSave(SaveCommand<T> cmd, SaveCommand<T> cmd2) {
        try {
            cmd.handle();
            return null;
        }
        catch (DuplicateKeyException ex) {
            if (cmd2 != null) {
                try {
                    cmd2.handle();
                    return null;
                } catch (Exception ex2) {
                    return new SqlError.GeneralSqlError(ex2.getMessage());
                }
            }
            else {
                return new SqlError.DuplicateKeyError(ex.getMessage());
            }
        }
        catch (MyBatisSystemException mex) {
            if (mex.getCause() != null) {
                return new SqlError.MybatisError(mex.getCause().getLocalizedMessage());
            }
            else {
                return new SqlError.MybatisError(mex.getMessage());
            }
        }
        catch (org.springframework.jdbc.BadSqlGrammarException bex) {
            return new SqlError.BadGrammarError(bex.getMessage());
        }
        catch (PSQLException pex) {
            return new SqlError.PostgresError(pex.getMessage());
        }
        catch (Exception ex) {
            return new GeneralError.GeneralApplicationError(ex.getMessage());
        }
    }

    public <T> Either<ApplicationError, T> handleSearch(Supplier<T> cmd) {
        try {
            var result = cmd.get();
            if (result == null)  {
                return Either.left(new SqlError.Warning("Empty search result"));
            }
            else {
                return Either.right(result);
            }
        }
        catch (MyBatisSystemException mex) {
            if (mex.getCause() != null) {
                return Either.left(new SqlError.MybatisError(mex.getCause().getLocalizedMessage()));
            }
            else {
                return Either.left(new SqlError.MybatisError(mex.getMessage()));
            }
        }
        catch (org.springframework.jdbc.BadSqlGrammarException bex) {
            return Either.left(new SqlError.BadGrammarError(bex.getMessage()));
        }
        /*
        catch (PSQLException pex) {
            return Either.left(new SqlError.GeneralSqlError(pex.getMessage()));
        }
         */
        catch (Exception ex) {
            return Either.left(new GeneralError.GeneralApplicationError(ex.getMessage()));
        }
    }


    public <T> Either<ApplicationError, T> handle(Supplier<T> cmd) {
        try {
            var result = cmd.get();
            if (result == null) {
                return Either.left(new GeneralError.Warning("Empty handle result"));
            } else {
                return Either.right(result);
            }
        } catch (Exception ex) {
            return Either.left(new GeneralError.GeneralApplicationError(ex.getMessage()));
        }
    }
}
