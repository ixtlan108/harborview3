package harborview.domain.functional;


import java.io.Serializable;
import java.util.NoSuchElementException;
import java.util.function.Function;

public abstract class Either<L, R> {

    private Either() {
    }

    public static <L, R> Either<L, R> right(R right) {
        return new Right<>(right);
    }

    public static <L, R> Either<L, R> left(L left) {
        return new Left<>(left);
    }

    public abstract L getLeft();

    public abstract R getRight();

    public abstract boolean isLeft();

    public abstract boolean isRight();

    public abstract R get();

    public abstract  <C> Either<L, C> andThen(Function<? super R,Either<L, C>> f);

    public static final class Left<L, R> extends Either<L, R> {

        private final L value;

        private Left(L value) {
            this.value = value;
        }

        @Override
        public L getLeft() {
            return value;
        }

        @Override
        public R getRight() {
            throw new NoSuchElementException("get() on Left");
        }

        @Override
        public boolean isLeft() {
            return true;
        }

        @Override
        public boolean isRight() {
            return false;
        }

        @Override
        public R get() {
            throw new NoSuchElementException("get() on Left");
        }

        @Override
        public <C> Either<L, C> andThen(Function<? super R, Either<L, C>> f) {
            return Either.left(value);
        }

    }

    public static final class Right<L, R> extends Either<L, R> implements Serializable {

        private final R value;

        private Right(R value) {
            this.value = value;
        }

        @Override
        public L getLeft() {
            throw new NoSuchElementException("getLeft() on Right");
        }

        @Override
        public R getRight() {
            return value;
        }

        @Override
        public boolean isLeft() {
            return false;
        }

        @Override
        public boolean isRight() {
            return true;
        }

        @Override
        public R get() {
            return value;
        }

        @Override
        public <C> Either<L, C> andThen(Function<? super R,Either<L, C>> f) {
            return f.apply(value);
        }

        /*
        public <C> Either<L, C> andThen(Either<L,R> result, Function<? super R, Either<L, C>> f) {
            if (result.isRight()) {
                return f.apply(result.getRight());
            }
            else {
                throw new NoSuchElementException("getLeft() on Right");
            }
        }

        public <C> Either<L, C> andThen(Function<? super R, Either<L, C>> f) {
            return null;
//            if (isOk()) {
//                return f.apply(this.ok().get());
//            } else {
//                return new Error<>(this.error().get());
//            }
        }

         */
    }
}
