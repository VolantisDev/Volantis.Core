/**
 * A base class for all Cloners to extend from.
 *
 * This is a requirement as some libraries may type check for
 * classes which extend this prototype.
 */
class ClonerBase {
    deep := false

    __New(deep := false) {
        this.deep := deep
    }

    Clone(val) {

    }
}
