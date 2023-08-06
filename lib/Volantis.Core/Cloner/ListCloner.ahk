/**
 * ListCloner can be used for cloning both lists and maps, and can
 * create either shallow or deep clones.
 *
 * A deep clone not only clones the parent list, but also clones all
 * objects within the map or list. Additionally, it recursively clones
 * the child maps and lists all the way down. This is useful if you need
 * an entirely new nested object that matches another one, so that changes to
 * child items don't affect the original.
 */
class ListCloner extends ClonerBase {
    Clone(val) {
        if (HasBase(val, Map.Prototype) || HasBase(val, Array.Prototype)) {
            val := val.Clone()

            if (this.deep) {
                for indexOrKey, originalValue in val {
                    val[indexOrKey] := this.Clone(originalValue)
                }
            }
        }

        return val
    }
}
