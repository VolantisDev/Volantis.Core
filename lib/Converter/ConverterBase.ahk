/**
 * A Converter is a generic concept for converting between units or value types.
 *
 * This base class is used for type checking so make sure to extend it for all converters.
 *
 * @todo Treat any object with a Convert method as a converter and use this as the contract?
 */
class ConverterBase {
    Convert(value) {
        return value
    }
}
