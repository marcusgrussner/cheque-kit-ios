extension String {
    /// Returns a copy of the text with the character at a 1-based position replaced, to
    /// simulate a misread character in a CMC-7 line.
    ///
    /// - Parameters:
    ///   - position: The 1-based position of the character to replace.
    ///   - character: The character to put in its place.
    /// - Returns: The text with that one character replaced.
    func replacing(position: Int, with character: Character) -> String {
        var characters = Array(self)
        characters[position - 1] = character
        return String(characters)
    }
}
