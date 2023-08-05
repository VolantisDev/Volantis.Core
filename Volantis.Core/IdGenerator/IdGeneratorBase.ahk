/**
 * An ID generator generates unique IDs following some type of logic.
 *
 * The most common implementation is UuidGenerator since it doesn't require tracking
 * a sequential numbering system, and it's extremely unlikely to generate duplicate
 * IDs.
 */
class IdGeneratorBase {
    Generate() {
        throw MethodNotImplementedException("IdGeneratorBase", "GenerateId")
    }
}
