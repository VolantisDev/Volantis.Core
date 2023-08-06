/**
 * This is used in the Volantis libraries when a base class requires a method to
 * be implemented by a subclass. Because the concept of an abstract class doesn't
 * exist, this exception is thrown whenever a required method is called that hasn't
 * yet been implemented.
 */
class MethodNotImplementedException extends ExceptionBase {
    __New(className := "", method := "", stack := -1) {
        message := "The called method is required but has not been implemented."
        super.__New(message, "", method, stack - 1)
    }
}
