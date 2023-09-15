/**
 * This is used as a parent class of list-type classes within the Volantis libraries.
 *
 * This allows things like Merger and Cloner implementations to treat other classes
 * that don't extend Map or Array like lists.
 *
 * Note that the implementing class is responsible for providing a list-like interface.
 *
 * The more specific MapLike and ListLike classes should be extended instead in most cases.
 */
class List extends Map {
    static ARRAY_FILTER_USE_VALUE := 0
    static ARRAY_FILTER_USE_KEY := 1
    static ARRAY_FILTER_USE_BOTH := 2

    ; This should always be true because
    forceShallowClone := true

    /**
     * Static methods for generic list-like operations
     */

    static IsArrayLike(value) {
        return (HasBase(value, Array.Prototype) || (HasProp(value, "isArrayLike") && value.isArrayLike))
    }

    static IsListLike(value) {
        return this.IsArrayLike(value) || this.IsMapLike(value)
    }

    static IsMapLike(value) {
        return (HasBase(value, Map.Prototype) || (HasProp(value, "isMapLike") && value.isMapLike))
    }

    /**
     * Clone can be used for cloning both lists and maps, and can
     * create either shallow or deep clones.
     *
     * A deep clone not only clones the parent list, but also clones all
     * objects within the map or list. Additionally, it recursively clones
     * the child maps and lists all the way down. This is useful if you need
     * an entirely new nested object that matches another one, so that changes to
     * child items don't affect the original.
     *
     * If a non-map-like and non-array-like value is passed, ListCloner will still
     * check for a Clone method on the value and call that if it exists.
     *
     * This should make it safe to pass any cloneable value to ListCloner.Clone,
     * but deep only has meaning for array-like and map-like objects.
     */
    static Clone(val, deep := true) {
        if (this.IsListLike(val)) {
            val := val.Clone()

            if (deep && !val.HasProp("forceShallowClone") || !val.forceShallowClone) {
                for indexOrKey, originalValue in val {
                    val[indexOrKey] := this.Clone(originalValue, deep)
                }
            }
        } else if HasMethod(val, "Clone") {
            val := val.Clone()
        } else {
            throw DataException("Value is not cloneable")
        }

        return val
    }

    /**
     * Turns an array into a map, or a map into an array.
     *
     * If the map keys are numeric, the same index will be preserved in the array
     * unless that index is already in use, in which case a new index value will be pushed.
     *
     * If a map's keys are not numeric, the array order is not guaranteed.
     */
    static Convert(listObj) {
        if (!this.IsListLike(listObj)) {
            throw DataException("mapOrArray must be list-like")
        }

        isArray := this.IsArrayLike(listObj)
        result := isArray ? Map() : []

        for keyOrIndex, val in listObj {
            if (isArray) {
                result[keyOrIndex] := val
            } else if (IsNumber(keyOrIndex)) {
                if (result.Has(keyOrIndex)) {
                    result.Push(val)
                } else {
                    result.InsertAt(keyOrIndex, val)
                }
            } else {
                result.Push(val)
            }
        }
    }

    static Diff(listObj1, listObj2) {
        if (!this.IsListLike(listObj1) || !this.IsListLike(listObj2)) {
            throw DataException("Both values must be list-like")
        }

        isArray := this.IsArrayLike(listObj1)
        result := isArray ? [] : Map()

        for keyOrIndex, val in listObj1 {
            matchingKey := this.Search(listObj2, val)

            if (!matchingKey) {
                if (isArray) {
                    result.Push(val)
                } else {
                    result[keyOrIndex] := val
                }
            }
        }

        for keyOrIndex, val in listObj2 {
            matchingKey := this.Search(listObj1, val)

            if (!matchingKey) {
                if (isArray) {
                    result.Push(val)
                } else {
                    result[keyOrIndex] := val
                }
            }
        }

        return result
    }

    static DiffKeys(listObj1, listObj2) {
        if (!this.IsListLike(listObj1) || !this.IsListLike(listObj2)) {
            throw DataException("Both values must be list-like")
        }

        isArray := this.IsArrayLike(listObj1)
        result := isArray ? [] : Map()

        for indexOrKey, val in listObj1 {
            if (!listObj2.Has(indexOrKey)) {
                if (isArray) {
                    result.Push(val)
                } else {
                    result[indexOrKey] := val
                }
            }
        }

        for indexOrKey, val in listObj2 {
            if (!listObj1.Has(indexOrKey)) {
                if (isArray) {
                    result.Push(val)
                } else {
                    result[indexOrKey] := val
                }
            }
        }

        return result
    }

    static Filter(listObj, filterCallback := "", mode := 0) {
        if (!this.IsListLike(listObj)) {
            throw DataException("list must be list-like")
        }

        if (!filterCallback) {
            filterCallback := ObjBindMethod(this, "_IsNonEmpty")
        }

        result := this.IsArrayLike(listObj) ? [] : Map()

        for keyOrIndex, value in listObj {
            params := ""

            if (mode == this.ARRAY_FILTER_USE_KEY) {
                params := [keyOrIndex]
            } else if (mode == this.ARRAY_FILTER_USE_BOTH) {
                params := [keyOrIndex, value]
            } else {
                params := [value]
            }

            if (filterCallback(params*)) {
                if (this.IsArrayLike(listObj)) {
                    result.Push(value)
                } else {
                    result[keyOrIndex] := value
                }
            }
        }

        return result
    }

    static _IsNonEmpty(value, key := "") {
        return value == ""
    }

    /**
     * Returns a map even if list is an array. The result will be flipped so that the keys or index of
     * list are the values, and the values of list are the keys.
     */
    static Flip(listObj, overwriteDuplicates := false) {
        if (!this.IsListLike(listObj)) {
            throw DataException("List object must be list-like")
        }

        isArray := this.IsArrayLike(listObj)
        result := isArray ? [] : Map()

        for keyOrIndex, val in listObj {
            if (!result.Has(val) || overwriteDuplicates) {
                result[val] := keyOrIndex
            }
        }

        return result
    }

    /**
     * Preserves keys from list1 for map-like objects, and returns new indexes for array-like objects.
     *
     * If list1 is a map and list2 is an array, a map is returned and keys are preserved.
     * If list1 is an array and list2 is a map, an array is returned without preserving keys.
     */
    static Intersect(list1, list2) {
        if (!this.IsListLike(list1) || !this.IsListLike(list2)) {
            throw DataException("Both values must be list-like")
        }

        isArray := this.IsArrayLike(list1)
        result := isArray ? [] : Map()

        for keyOrIndex, val in list1 {
            matchingKey := this.Search(list2, val)

            if (matchingKey) {
                if (isArray) {
                    result.Push(val)
                } else {
                    result[keyOrIndex] := val
                }
            }
        }

        return result
    }

    static IntersectKeys(list1, list2) {
        if (!this.IsListLike(list1) || !this.IsListLike(list2)) {
            throw DataException("Both values must be list-like")
        }

        isArray := this.IsArrayLike(list1)
        result := isArray ? [] : Map()

        for indexOrKey, val in list1 {
            if (list2.Has(indexOrKey)) {
                if (isArray) {
                    result.Push(val)
                } else {
                    result[indexOrKey] := val
                }
            }
        }

        return result
    }

    /**
     * Creates a list that is the intersection of list1 and list2 by comparing both keys and values together.
     *
     * Map("foo", "bar") and Map("bar", "bar") do not intersect because while they both share the same value, the key for that value differs.
     *
     * For arrays, the result is still re-keyed, but contains only values where list1 and list2 both had the same index.
     */
    static IntersectWithKeys(list1, list2) {
        if (!this.IsListLike(list1) || !this.IsListLike(list2)) {
            throw DataException("Both values must be list-like")
        }

        isArray := this.IsArrayLike(list1)
        result := isArray ? [] : Map()

        for indexOrKey, val in list1 {
            if (list2.Has(indexOrKey) && list2[indexOrKey] == val) {
                if (isArray) {
                    result.Push(val)
                } else {
                    result[indexOrKey] := val
                }
            }
        }

        return result
    }

    /**
     * Returns a new array containing all of the keys (or indexes) from the existing list.
     */
    static Keys(listObj) {
        if (!this.IsListLike(listObj)) {
            throw DataException("mapOrArray must be list-like")
        }

        result := []

        for keyOrIndex in listObj {
            result.Push(keyOrIndex)
        }

        return result
    }

    /**
     * Merges two lists or list-like objects together. The mergeable types are:
     * - Array and anything that inherits from Array.Prototype
     * - Map and anything that inherits from Map.Prototype
     * - ArrayLike, anything that inherits from this.Prototype, or anything
     *   with a property isArrayLike that returns a truthy value
     * - MapLike and anything that inherits from this.Prototype, or anything
     *   with a property isMapLike that returns a truthy value
     *
     * The items in value2 are always merged on top of the items in value1. The
     * result is a new list-like object that contains a combination of the items
     * from both lists. Where the same key exists in both lists, the value from list
     * 2 will overwrite the value from list 1.
     *
     * For array-like lists, the indexes of list 1 are preserved, and the items from
     * list 2 are appended to the end of the new list. All items from list 2 are added
     * to list 1, even if some or all values already exist in list 1, since numeric
     * arrays don't have keys to match against.
     *
     * Deep merging will also merge child list-like objects recursively. Note that this
     * includes all list-like objects, not just objects of the same type. For example,
     * a map containing arrays will merge both the parent map items and the child arrays.
     * Similarly, if those arrays had maps or arrays as children, those would be merged
     * as well, until there are no more child list-like objects to merge.
     *
     * It is important that the list-like objects being merged are not circular when
     * using deep merging, or the app will crash. For example:
     *
     * map1 := Map()
     * map1["childItem"] := Map("parent", map1)
     * map2 := Map("childItem", Map())
     *
     * merged := List.Merge(map1, map2, true)
     *
     * This will cause an infinite recursion loop because map1 is a child of itself.
     */
    static Merge(value1, value2, deep := true) {
        value1 := value1.Clone()

        if (this.IsArrayLike(value1) && this.IsArrayLike(value2)) {
            for index, val in value2 {
                if (deep && idx := this._getIndex(value1, val)) {
                    value1[idx] := this.Merge(value1[idx], val, deep)
                } else {
                    value1.Push(val)
                }
            }
        } else if (this.IsMapLike(value1) && this.IsMapLike(value2)) {
            for key, val in value2 {
                if (deep && value1.Has(key)) {
                    value1[key] := this.Merge(value1[key], val, deep)
                } else {
                    value1[key] := val
                }
            }
        } else {
            value1 := value2
        }

        return value1
    }

    static _getIndex(arr, val) {
        idx := ""

        for checkIndex, checkVal in arr {
            if (checkVal == val) {
                idx := checkIndex
                break
            }
        }

        return idx
    }

    /**
     * Searches a list-like or map-like object for a given value.
     *
     * If a field is provided, the searched values are assumed to be
     * map-like or array-like as well, and the field should be either
     * the key or index to search within.
     *
     * Deep searching can be achieved by separating nested field values
     * with a dot (.). For example, if the field is "foo.bar", the
     * value of the "bar" key within the "foo" key will be searched.
     *
     * If your keys contain dots, you can disable deep matching by
     * setting deep to false, which will then search for the exact
     * key provided in the main list.
     */
    static Search(listObj, value, field := "", deep := true, numberOfResults := 1) {
        if (field && deep) {
            return this._SearchDeep(value, field)
        }

        result := numberOfResults == 1 ? "" : []

        if (this.IsArrayLike(listObj) || this.IsMapLike(listObj)) {
            for key, val in listObj {
                if (field) {
                    if (!this.IsArrayLike(val) && !this.IsMapLike(val)) {
                        continue
                    }

                    if (!val.Has(field)) {
                        continue
                    }

                    val := val[field]
                }

                if (val == value) {
                    if (numberOfResults == 1) {
                        result := key
                        break
                    } else {
                        result.Push(key)

                        if (result.Length == numberOfResults) {
                            break
                        }
                    }
                }
            }

            return result
        } else {
            throw DataException("Value must be a list-like or map-like object")
        }
    }

    /**
     * Searches a list-like or map-like object for a given value by first splitting the provided field
     * by the dot (.) character, and then recursively searching the value.
     *
     * For example, if the field is "foo.bar", the value of the "bar" key within the "foo" key of
     * the provided value will be searched.
     *
     * Don't use this method directly, it works best when called from Search.
     */
    static _SearchDeep(value, field) {
        if (Type(field) == "String") {
            fields := StrSplit(field, ".")
        }

        if (!field.HasBase(Array.Prototype)) {
            throw DataException("Field must be a string or an array of strings")
        }

        result := ""
        currentList := value

        for field in fields {
            if (!this.IsArrayLike(currentList) && !this.IsMapLike(currentList)) {
                break
            }

            if (!currentList.Has(field)) {
                break
            }

            ; Force a shallow search so that we don't cause a loop.
            resultItem := this.Search(currentList, field, false)

            if (!resultItem) {
                break
            }

            if (result) {
                result .= "."
            }

            result .= resultItem
            currentList := currentList[field]
        }

        return result
    }

    /**
     * Sort works with arrays only. If an map is passed in, the result
     * will be an array.
     *
     * If array-like sorting is needed for map-like objects, sort the keys
     * instead of the values and then loop over the sorted keys array.
     */
    static Sort(listObj, sortCallback := "") {
        if (!this.IsListLike(listObj)) {
            throw DataException("mapOrArray must be list-like")
        }

        if (!sortCallback) {
            sortCallback := ObjBindMethod(this, "_Compare")
        }

        sortString := ""

        for , value in listObj {
            if (sortString) {
                sortString .= "`n"
            }

            sortString .= StrReplace(value, "`n", "``n")
        }

        sortedString := Sort(sortString,, sortCallback)
        sorted := []

        Loop Parse, sortedString, "`n" {
            sorted.Push(StrReplace(A_LoopField, "``n", "`n"))
        }

        return sorted
    }

    static _Compare(value1, value2) {
        if (IsNumber(value1) && IsNumber(value2)) {
            if (value1 > value2) {
                return 1
            } else if (value1 < value2) {
                return -1
            } else {
                return 0
            }
        } else {
            return StrCompare(value1, value2)
        }
    }

    /**
     * Sorts the keys of the provided list and returns an array of
     * sorted keys.
     *
     * If an array is passed in, the result will still be an array of
     * indexes, but arrays are already sorted so the operation only
     * serves a purpose if a custom sort callback is also used.
     */
    static SortKeys(listObj, sortCallback := "") {
        if (!this.IsListLike(listObj)) {
            throw DataException("mapOrArray must be list-like")
        }

        if (!sortCallback) {
            sortCallback := ObjBindMethod(this, "_Compare")
        }

        sortString := ""

        for keyOrIndex in listObj {
            if (sortString) {
                sortString .= "`n"
            }

            sortString .= StrReplace(keyOrIndex, "`n", "``n")
        }

        sortedString := Sort(sortString,, sortCallback)
        sorted := []

        Loop Parse, sortedString, "`n" {
            sorted.Push(StrReplace(A_LoopField, "``n", "`n"))
        }

        return sorted
    }

    static Unique(listObj) {
        if (!this.IsListLike(listObj)) {
            throw DataException("List object must be list-like")
        }

        isArray := this.IsArrayLike(listObj)
        result := this.Flip(this.Flip(listObj, false), false)

        if (isArray) {
            result := this.Values(result)
        }

        return result
    }

    /**
     * Returns a new array containing all of the values from the existing list.
     */
    static Values(listObj) {
        if (!this.IsListLike(listObj)) {
            throw DataException("mapOrArray must be list-like")
        }

        result := []

        for , val in listObj {
            result.Push(val)
        }

        return result
    }

    /**
     * Instance methods available for convenience.
     */

    Clone(deep := false) {
        if (deep) {
            return this.Prototype.Clone(this, deep)
        } else {
            return super.Clone()
        }
    }

    Convert() {
        return this.Prototype.Convert(this)
    }

    Diff(otherList) {
        return this.Prototype.Diff(this, otherList)
    }

    DiffKeys(otherList) {
        return this.Prototype.DiffKeys(this, otherList)
    }

    Filter(filterCallback := "", mode := 0) {
        return this.Prototype.Filter(this, filterCallback, mode)
    }

    Flip(overwriteDuplicates := false) {
        return this.Prototype.Flip(this, overwriteDuplicates)
    }

    Intersect(otherList) {
        return this.Prototype.Intersect(this, otherList)
    }

    IntersectKeys(otherList) {
        return this.Prototype.IntersectKeys(this, otherList)
    }

    IntersectWithKeys(otherList) {
        return this.Prototype.IntersectWithKeys(this, otherList)
    }

    IsArrayLike() {
        return this.Prototype.IsArrayLike(this)
    }

    IsMapLike() {
        return this.Prototype.IsMapLike(this)
    }

    Keys() {
        return this.Prototype.Keys(this)
    }

    Merge(otherList, deep := true) {
        return this.MergeFrom(otherList, deep)
    }

    MergeFrom(otherList, deep := true) {
        return this.Prototype.Merge(this, otherList, deep)
    }

    MergeTo(otherList, deep := true) {
        return this.Prototype.Merge(otherList, this, deep)
    }

    Search(value, field := "", deep := true, numberOfResults := 1) {
        return this.Prototype.Search(this, value, field, deep, numberOfResults)
    }

    Sort(sortCallback := "") {
        return this.Prototype.Sort(this, sortCallback)
    }

    SortKeys(sortCallback := "") {
        return this.Prototype.SortKeys(this, sortCallback)
    }

    Unique() {
        return this.Prototype.Unique(this)
    }

    Values() {
        return this.Prototype.Values(this)
    }
}
