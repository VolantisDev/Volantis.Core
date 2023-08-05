class ToastNotifier extends NotifierBase {
    Notify(message, title := "", level := "info") {
        if (title == "") {
            title := this.defaultTitle
        }

        ; TODO Update toast notifier options according to message level
        options := 17
        TrayTip(message, title, options)
    }
}
