# hless - less with syntax highlighting

```
Usage: hless [-l lexer] [less options ...] [file]
    -l LEXER, --lexer LEXER          the pygments lexer to use
    -h, --help                       show this help

Examples:
# Open the file hless.cr in less and highlight it using the ruby lexer
$ hless -l rb hless.cr
# Open the file foo.rb and highlight it with the lexer guessed from the file
$ hless foo.rb
# Follow the tail of a logfile and highlight its contents using the ruby lexer
$ tail -f log/development.log | hless -l rb +F
```

## Dependencies

- pygments

## Build Dependencies

- crystal

## Building

crystal build --release hless.cr
