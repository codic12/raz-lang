module token;

enum TokenType {
    ILLEGAL,
    EOF,
    IDENT,
    INT,
    ASSIGN,
    PLUS,
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    FUNCTION,
    LET,
    CONST,
    RET
}

struct Token {
    TokenType type;
    string literal;
}

// lookup tables are pretty awesome
TokenType[string] keywordTable;

static this() {
    keywordTable = [
        "fun": TokenType.FUNCTION,
        "let": TokenType.LET,
        "const": TokenType.CONST
    ];
}

const lookupIdent = (string ident) => ident in keywordTable ? keywordTable[ident] : TokenType.IDENT;
