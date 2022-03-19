# console-colors


## Goals

`console-colors` is an attempt towards making the **ultimate no-hassle console color library for D.**

It is meant as a spiritual successor of the `colorize` [package](https://github.com/yamadapc/d-colorize) and improves it based upon usage on a few areas.


## Features

- Use 16 different colors in the terminal, for foreground and background.

- Color information can be given in two ways:
   - Within text with easy-to-remember tags, such as `"my <blue> text is <red>coloured</red></blue>"`
     Syntax errors within these tags throw, for the moment.
   - with string helper UFCS functions, such as `"my" ~ ("text is " ~ "coloured".red).blue`

- Portable with a special `cwrite[f][ln]` call, like the `colorize` package.
  Indeed, color information need to be **inline within text**, to properly nest in format strings.
  `console-colors` has a color stack to restore the previously set color.

- All colors have an easy shortcut like `.lmagenta` or `.white`, making it easier to add color in the first place (at the cost of your namespace).

  ```d
  try
  {
      // do something
  }
  catch(Exception e)
  {
      cwritefln("<lred>error:</lred> <white>%s</white>", e.msg);
  }
  ```

- Colors can be disabled globally, with `disableConsoleColors()`.
  It is an often wanted thing in command-line tools with colors.
  Colors are also disabled if `stdout` isn't a terminal, or if the terminal initialization failed.

We are heading towards the ultimate console in D. Reaching for the stars here.
You have no excuse anymore not to have colors in your terminal.


_If it's worth having a command-line, then it's worth having colours. - Adam Smith, Wealth of Nations_
