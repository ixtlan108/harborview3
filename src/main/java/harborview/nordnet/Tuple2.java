package harborview.nordnet;

public class Tuple2<T1,T2> {
    private final T1 _first;
    private final T2 _second;
    public Tuple2(T1 first, T2 second) {
        this._first = first;
        this._second = second;
    }
    public T1 first() {
        return _first;
    }
    public T2 second() {
        return _second;
    }

    @SuppressWarnings("unchecked")
    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Tuple2)) {
            return false;
        }
        Tuple2<T1,T2> other = (Tuple2<T1,T2>)obj;

        return ((_first.equals(other.first())) &&
                (_second.equals(other.second())));
    }
    @Override
    public int hashCode() {
        return (_first.hashCode() ^ _second.hashCode());
    }
}
