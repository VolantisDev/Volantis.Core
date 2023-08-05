# Volantis.CoreLib

## Introduction

This is a library of shared classes for AutoHotKey.  It is intended to be used as a submodule in other projects.

It is a dependency of higher-level libraries.

Better documentation is to come after the library structure is more stable.

## Installation

The current recommended approach to installing this library is by adding it as a submodule to your project.  This allows you to easily update to the latest version of the library, while keeping the files within your application directory for easy include file building.

## Usage

In general, all classes are intended to be instantiated as objects, which then contain functions for accessing whatever functionality the class provides.

For example, to debug a variable, instantiate the Debugger class, then call the Inspect function. For simple classes, this can be done on-the-fly in one line, like this:

```autohotkey
    myVar := Map("key1", "value1", "key2", "value2")
    Debugger.Inspect(myVar)
```

## TestLib Dependency

An important note is that using any of the *.test.ahk classes requires Volantis.TestLib, however it is not listed under dependencies or devDependencies of this library because this library is a dependency of TestLib.