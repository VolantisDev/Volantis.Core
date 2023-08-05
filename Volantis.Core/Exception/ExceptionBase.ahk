/**
 * A base class for exceptions within Volantis libraries, and can also be extended
 * as a base exception class for any other scripts or applications that make use of
 * these libraries.
 *
 * It essentially just wraps Error, but automatically passes in a stack line identifier
 * for the what variable if undefined.
 *
 * By default, this will point to the function that called the exception class. However,
 * other exceptions can pass a stack value in to keep this level consistent even with
 * nested exception classes.
 *
 * Since the ExceptionBase constructor calls the Error constructor, it will by default
 * use -2 as the stack value, which will point to the function that called the ExceptionBase.
 *
 * Generally, each exception class that calls a parent constructor should subtract 1 from
 * the stack value, so that the stack value will point to the function that originally threw
 * an exception, and not just to a higher exception class.
 */
class ExceptionBase extends Error {
    __New(message, what := "", extra := "", stack := -1) {
        if (!what) {
            what := stack - 1
        }

        super.__New(message, what, extra)
    }
}
