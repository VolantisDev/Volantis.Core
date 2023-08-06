/**
 * This is used as a parent class of list-type classes within the Volantis libraries.
 *
 * This allows things like Merger and Cloner implementations to treat other classes
 * that don't extend Map or Array like lists.
 *
 * Note that the implementing class is responsible for providing a list-like interface.
 *
 * The more specific MapLike and ListLike classes should be extended instead in most cases.
 */
class ListBase {

}
