/**
 * A simple converter that turns an AutoHotKey timestamp into a Unix timestamp.
 */
class UnixTimestampConverter extends ConverterBase {
    Convert(unixTimestamp) {
        return DateAdd(19700101000000, unixTimestamp, "S")
    }
}
