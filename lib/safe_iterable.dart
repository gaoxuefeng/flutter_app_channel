
/**
 * Created by Gao Xuefeng
 * on 2020/10/30
 */
 extension SafeIterable<E> on Iterable<E> {
  E safeElementAt(int index) {
    if (index < length && index >= 0) {
      return elementAt(index);
    }
    return null;
  }
}
