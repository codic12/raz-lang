module helper;

const partOfIdent = (char c) => 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' || c == '_';
const isDigit = (char c) => '0' <= c && c <= '9';
