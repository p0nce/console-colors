# console-colors

_If it's worth having a command-line, then it's worth having colours. - Adam Smith, Wealth of Nations_

`console-colors` is an attempt towards making the **ultimate no-hassle console color library for D.**

- Portable (Unix, Windows) with a special `cwrite[f][ln]` call, like the `colorize` package.
- Color information is **inline within text**, like the `colorize` package.
- Color information is given within text with HTML-like tags, such as `my text is <red>coloured</red>`
- Doesn't use VT100 ANSI sequences, in order to nest color definitions.
- Colors can be disabled globally.
- Easy API with shortcuts like `.lyellow` or `.red`
- Support CTRL-C / CTRL-Z etc.

Towards the ultimate console cWe are reaching for the stars here.
You have no excuse anymore not to have colors in your terminal.
