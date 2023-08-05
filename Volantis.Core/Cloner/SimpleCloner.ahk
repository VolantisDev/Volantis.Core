/**
 * SimpleCloner is an extremely basic Cloner implementation that
 * calls the Clone method of the value being cloned.
 *
 * While it is simpler to simply call the Clone method directly,
 * this class allows for basic cloning wherever the Cloner API is
 * being used.
 */
class SimpleCloner extends ClonerBase {
    Clone(val) {
        return val.Clone()
    }
}
