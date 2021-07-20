module lexer;

import token;
import std.algorithm.comparison : predSwitch;
import std.conv : to;
import std.stdio;
import error;
import helper;
import std.string : splitLines;
import std.array : replicate;

private void runTests(Lexer lexer, Token[] tests, bool exitOnFailure = true) {
    foreach (test; tests) {
        Token tok;
        try {
            tok = lexer.nextToken();
        } catch (LexErrorInfo e) {
            writeln("\u001b[31mSyntax error on line "
                    ~ e.line.to!string
                    ~ ", col " ~ e.col.to!string
                    ~ "; invalid token\u001b[0m");
            writeln(lexer.input.splitLines[e.line - 1]);
            writeln(e.col > 1 ? (replicate(" ", e.col - 2) ~ "^") : "^");
            exitOnFailure && assert(false);
        }
        tok.writeln;
        test.writeln;
        if (tok.type != test.type) {
            writeln("\u001b[31mToken type not the same as specified in test\u001b[0m");
            exitOnFailure && assert(false);
        }
        if (tok.literal != test.literal) {
            writeln("\u001b[31mToken literal not the same as specified in test\u001b[0m");
            exitOnFailure && assert(false);
        }
    }
}

unittest {
    // Lexer test case 1
    // Should be a success
    string input = `=+(){},;`;
    Lexer lexer = Lexer(input);
    Token[] tests = [
        Token(TokenType.ASSIGN, "="),
        Token(TokenType.PLUS, "+"),
        Token(TokenType.LPAREN, "("),
        Token(TokenType.RPAREN, ")"),
        Token(TokenType.LBRACE, "{"),
        Token(TokenType.RBRACE, "}"),
        Token(TokenType.COMMA, ","),
        Token(TokenType.SEMICOLON, ";"),
        Token(TokenType.EOF, "")
    ];
    lexer.runTests(tests);
}

unittest {
    // Lexer test case 3
    // Should be a success 
    string input = `
        const x = 5;
        const y = 10;
        const add = fun(x int, y int) {
            ret x + y;
        }
        const res = add(x, y);
    `;
    Lexer lexer = Lexer(input);
    Token[] tests = [
        Token(TokenType.CONST, "const"),
        Token(TokenType.IDENT, "x"),
        Token(TokenType.ASSIGN, "="),
        Token(TokenType.INT, "5"),
        Token(TokenType.SEMICOLON, ";"),
        Token(TokenType.CONST, "const"),
        Token(TokenType.IDENT, "y"),
        Token(TokenType.ASSIGN, "="),
        Token(TokenType.INT, "10"),
        Token(TokenType.SEMICOLON, ";"),
        Token(TokenType.CONST, "const"),
        Token(TokenType.IDENT, "add"),
        Token(TokenType.ASSIGN, "="),
        Token(TokenType.FUNCTION, "fun"),
        Token(TokenType.LPAREN, "("),
        Token(TokenType.IDENT, "x"),
        Token(TokenType.IDENT, "int"),
        Token(TokenType.COMMA, ","),
        Token(TokenType.IDENT, "y"),
        Token(TokenType.IDENT, "int"),
        Token(TokenType.RPAREN, ")"),
        Token(TokenType.LBRACE, "{"),
        Token(TokenType.RET, "ret"),
        Token(TokenType.IDENT, "x"),
        Token(TokenType.PLUS, "+"),
        Token(TokenType.IDENT, "y"),
        Token(TokenType.SEMICOLON, ";"),
        Token(TokenType.RBRACE, "}"),
        Token(TokenType.SEMICOLON, ";"),
        Token(TokenType.CONST, "const"),
        Token(TokenType.IDENT, "res"),
        Token(TokenType.ASSIGN, "="),
        Token(TokenType.IDENT, "add"),
        Token(TokenType.LPAREN, "("),
        Token(TokenType.IDENT, "x"),
        Token(TokenType.COMMA, ","),
        Token(TokenType.IDENT, "ten"),
        Token(TokenType.RPAREN, ")"),
        Token(TokenType.SEMICOLON, ";"),
        Token(TokenType.EOF, "")
    ];
    lexer.runTests(tests);
}

struct Lexer {
    string input = "";
    size_t pos = 0;
    size_t readPos = 0;
    char ch = 0;

    Token nextToken() {
        readChar;
        gobbleWhitespace;
        switch (ch) {
        case '=':
            return Token(TokenType.ASSIGN, ch.to!string);
        case ';':
            return Token(TokenType.SEMICOLON, ch.to!string);
        case '(':
            return Token(TokenType.LPAREN, ch.to!string);
        case ')':
            return Token(TokenType.RPAREN, ch.to!string);
        case ',':
            return Token(TokenType.COMMA, ch.to!string);
        case '+':
            return Token(TokenType.PLUS, ch.to!string);
        case '{':
            return Token(TokenType.LBRACE, ch.to!string);
        case '}':
            return Token(TokenType.RBRACE, ch.to!string);
        case 0:
            return Token(TokenType.EOF, "");
        default:
            // return Token(TokenType.ILLEGAL, ch.to!string);
            if (ch.partOfIdent) {
                Token token;
                token.literal = readIdent;
                token.type = token.literal.lookupIdent;
                return token;
            } else if (ch.isDigit) {
                Token token;
                token.literal = readNumber;
                token.type = TokenType.INT;
                return token;
            }
            throw lexErrorPosition(readPos, input);
        }
    }

    string readIdent() {
        auto origpos = pos;
        while (ch.partOfIdent)
            readChar;
        return input[origpos .. pos];
    }

    string readNumber() {
        auto origpos = pos;
        while (ch.isDigit) {
            readChar;
        }
        return input[origpos .. pos];
    }

    void readChar() {
        ch = readPos >= input.length ? 0 : input[readPos];
        pos = readPos;
        readPos++;
    }

    void gobbleWhitespace() {
        while (ch == ' ' || ch == '\n' || ch == '\t' || ch == '\r' || ch == '\f') {
            readChar();
        }
    }
}
