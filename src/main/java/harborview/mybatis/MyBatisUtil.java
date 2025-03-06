package harborview.mybatis;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Component;

import java.util.function.Consumer;
import java.util.function.Function;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
public class MyBatisUtil {

    private final Logger logger = LoggerFactory.getLogger(MyBatisUtil.class);
    private final SqlSession session;

    public MyBatisUtil(SqlSession session) {
        this.session = session;
    }

    public <T> T withSession(Function<SqlSession,T> fn) {
        return withSession(fn, null);
    }
    public <T> T withSession(Function<SqlSession,T> fn, Consumer<Exception> errorHandler) {
        try {
            return fn.apply(session);
        }
        catch (Exception ex) {
            if (errorHandler == null){
                logger.error(ex.getMessage());
                throw ex;
            }
            else {
                errorHandler.accept(ex);
            }
            return null;
        }
    }

    public void withSessionConsumer(Consumer<SqlSession> consumer) {
        withSessionConsumer(consumer, null);
    }
    public void withSessionConsumer(Consumer<SqlSession> consumer, Consumer<Exception> errorHandler) {
        try {
            consumer.accept(session);
        }
        catch (Exception ex) {
            if (errorHandler == null){
                logger.error(ex.getMessage());
                throw ex;
            }
            else {
                errorHandler.accept(ex);
            }
        }
    }

}
