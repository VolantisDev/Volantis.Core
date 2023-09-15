class RegExp {
    static Split(str, pattern, options := "") {
        arr := []
        prevPos := 1
        prevLen := 0

        while RegExMatch(str, options . "O)" . pattern, &m, m ? m.Pos + m.Len : 1) {
            arr.Push(SubStr(str, prevPos + prevLen, m.Pos - prevPos - prevLen))
            prevPos := m.Pos, prevLen := m.Len
        }

        arr.Push(SubStr(str, prevPos + prevLen))

        Return arr
    }
}
