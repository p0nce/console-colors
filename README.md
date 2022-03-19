# console-colors

`console-colors` is an attempt towards making the **ultimate no-hassle console color library for D.**

- Color information can be given in two ways:
   - Within text with HTML-like tags, such as `"my <blue> text is <red>coloured</red></blue>"`
   - with string helper UFCS functions, such as `("my" ~ ("text is " ~ coloured.red)).blue`

- Portable (Unix, Windows) with a special `cwrite[f][ln]` call, like the `colorize` package.
  Indeed, color information need to be **inline within text**, to properly nest in format strings.
  All colors have an easy shortcut like `.lyellow` or `.red`.

  ```d
  try
  {
      // do something
  }
  catch(Exception e)
  {
      cwritefln("<lred>error:</lred> <white>%s</white>", escapeHTML(e.msg));
  }

- Colors can be disabled globally, with 
  They are also disabled if `stdout` isn't a terminal.


- Support CTRL-C / CTRL-Z etc.

Towards the ultimate console cWe are reaching for the stars here.
You have no excuse anymore not to have colors in your terminal.


_If it's worth having a command-line, then it's worth having colours. - Adam Smith, Wealth of Nations_
