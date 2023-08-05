class IncludeUpdaterBase {
    mainLibDir := ""
    appDir := ""

    __New(appDir, mainLibDir := "Lib") {
        this.appDir := appDir
        this.mainLibDir := mainLibDir
    }

    GetIncludeBuilder(libDir, testBuilder := false) {
        return MethodNotImplementedException("IncludeUpdaterBase", "GetIncludeBuilder")
    }

    GetIncludeWriter(libDir, testWriter := false) {
        return MethodNotImplementedException("IncludeUpdaterBase", "GetIncludeWriter")
    }

    UpdateIncludes() {
        libsUpdated := false

        Loop Files this.appDir . "\" . this.mainLibDir . "\*", "D" {
            libUpdated := this.GenerateIncludeFile(A_LoopFileFullPath, true)

            if (libUpdated) {
                libsUpdated := true
            }
        }

        return libsUpdated
    }

    GenerateIncludeFile(libDir, includeTests := false) {
        includeBuilder := this.GetIncludeBuilder(libDir, false)
        includeWriter := this.GetIncludeWriter(libDir, false)
        updated := includeWriter.WriteIncludes(includeBuilder.BuildIncludes())

        if (includeTests) {
            testBuilder := this.GetIncludeBuilder(libDir, true)
            testWriter := this.GetIncludeWriter(libDir, true)
            testsUpdated := testWriter.WriteIncludes(testBuilder.BuildIncludes())

            if (testsUpdated) {
                updated := true
            }
        }

        return updated
    }
}
