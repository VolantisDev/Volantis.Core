class NotifierBase {
    config := Map()
    defaultTitle := ""

    __New(config := "", defaultTitle := "") {
        if (config != "") {
            this.config := config
        }

        if (defaultTitle != "") {
            this.defaultTitle := defaultTitle
        }
    }

    /**
    * ABSTRACT METHODS
    */

    Notify(message, title := "", level := "info") {
        throw MethodNotImplementedException("NotifierBase", "Notify")
    }
}
