module error;

class LexErrorInfo : Exception {
    size_t line;
    size_t col;

    this(size_t line, size_t col) {
        this.line = line;
        this.col = col;
        super(null);
    }
}

// credits to Flexibility on Crying Universe
LexErrorInfo lexErrorPosition(size_t idx, string text) {
    size_t line = 1;
    size_t col = 1;

    foreach (i; 0 .. idx) {
        if (text[i] == '\r')
            continue;
        if (text[i] == '\n') {
            line++;
            col = 1;
        } else {
            col++;
        }
    }

    return new LexErrorInfo(line, col);
}
