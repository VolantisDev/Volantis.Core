/**
 * An InvalidParameterException can be used within functions to perform simple parameter
 * validation.
 *
 * Typically, it is not instantiated directly with a throw call, but rather called by calling
 * the static CheckTypes, CheckEmpty, and CheckBetween methods.
 *
 * This is sometimes used in the Volantis libraries to validate constructor parameters in order
 * to avoid hard-to-diagnose errors in an application.
 */
class InvalidParameterException extends ExceptionBase {
    __New(message, parameterName, value := "", requiredType := "", extraInfo := "", stack := -1) {
        message := "The parameter '" . parameterName . "' (type is '" . Type(value) . "') is invalid."

        if (requiredType != "") {
            message .= " The required type is '" . requiredType . "'."
        }

        if (extraInfo != "") {
            message .= " " . extraInfo
        }

        super.__New(message, "", value, stack - 1)
    }

    static CheckTypes(className, params*) {
        nextParam := 1

        while (params.Has(nextParam)) {
            paramName := params[nextParam]
            paramVal := params[nextParam + 1]
            paramType := Type(paramVal)
            reqType := params[nextParam + 2]
            nextParam := nextParam + 3

            if (reqType == "") {
                reqType := "String"
            }

            reqTypes := StrSplit(reqType, "|")
            validType := false

            for index, checkType in reqTypes {
                validType := (paramType == checkType)

                if (!validType) {
                    if (paramType != "String" && paramType != "Integer" && paramType != "Float") {
                        validType := HasBase(paramVal, %reqType%.Prototype)
                    }
                }

                if (validType) {
                    break
                }
            }

            if (!validType) {
                throw InvalidParameterException(-3, paramName, paramVal, reqType)
            }
        }
    }

    static CheckEmpty(className, params*) {
        nextParam := 1

        while (params.Has(nextParam)) {
            paramName := params[nextParam]
            paramVal := params[nextParam + 1]
            nextParam := nextParam + 2

            if (paramVal == "") {
                throw InvalidParameterException(-1, paramName, paramVal, "")
            }
        }
    }

    static CheckBetween(className, params*) {
        nextParam := 1

        while (params.Has(nextParam)) {
            paramName := params[nextParam]
            paramVal := params[nextParam + 1]
            rangeStart := params[nextParam + 2]
            rangeStop := params[nextParam + 3]
            nextParam := nextParam + 4

            InvalidParameterException.CheckTypes(-1, paramName, paramVal, "Integer|Float", "rangeStart", rangeStart, "Integer|Float", "rangeStop", rangeStop, "Integer|Float")

            if (paramVal > rangeStop) {
                throw InvalidParameterException(-1, paramName, paramVal, "", "Provided current position is not within the upper bound of the range (" . rangeStop . ").")
            }

            if (paramVal < rangeStart) {
                throw InvalidParameterException(-1, paramName, paramVal, "", "Provided current position is not within the lower bound of the range (" . rangeStart . ").")
            }
        }
    }
}
