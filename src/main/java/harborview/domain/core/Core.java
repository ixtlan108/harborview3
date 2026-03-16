package harborview.domain.core;

import harborview.domain.error.ApplicationError;
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
            try {
                cmd2.handle();
                return null;
            }
            catch (Exception ex2) {
                return new SqlError.GeneralSqlError(ex2.getMessage());
            }
        }
        catch (MyBatisSystemException mex) {
            if (mex.getCause() != null) {
                //return new SqlError.MyBatisError(mex.getCause().getLocalizedMessage());
                return null;
            }
            else {
                //return new SqlError.MyBatisError(mex.getMessage());
                return null;
            }
        }
        catch (org.springframework.jdbc.BadSqlGrammarException bex) {
            //return new SqlError.BadGrammarError(bex.getMessage());
            return null;
        }
        catch (PSQLException pex) {
            //return new SqlError.GeneralSqlError(pex.getMessage());
            return null;
        }
        catch (Exception ex) {
            //return new GeneralError.GeneralApplicationError(ex.getMessage());
            return null;
        }
    }

    public <T> Either<ApplicationError, T> handleSearch(Supplier<T> cmd) {
        try {
            var result = cmd.get();
            if (result == null)  {
                //return Either.left(new ApplicationWarning.NotFound("Empty search result"));
                return null;
            }
            else {
                return Either.right(result);
            }
        }
        catch (MyBatisSystemException mex) {
            if (mex.getCause() != null) {
                //return Either.left(new SqlError.MyBatisError(mex.getCause().getLocalizedMessage()));
                return null;
            }
            else {
                //return Either.left(new SqlError.MyBatisError(mex.getMessage()));
                return null;
            }
        }
        catch (org.springframework.jdbc.BadSqlGrammarException bex) {
            //return Either.left(new SqlError.BadGrammarError(bex.getMessage()));
            return null;
        }
        /*
        catch (PSQLException pex) {
            return Either.left(new SqlError.GeneralSqlError(pex.getMessage()));
        }
         */
        catch (Exception ex) {
            //return Either.left(new GeneralError.GeneralApplicationError(ex.getMessage()));
            return null;
        }
    }


    public <T> Either<ApplicationError, T> handle(Supplier<T> cmd) {
        try {
            var result = cmd.get();
            if (result == null) {
                //return Either.left(new ApplicationWarning.NotFound("Empty search result"));
                return null;
            } else {
                return Either.right(result);
            }
        } catch (Exception ex) {
            return null;
        }
    }
}
