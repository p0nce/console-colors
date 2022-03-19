# console-colors


## Goals

`console-colors` is an attempt towards making the **ultimate zero-hassle console color library for D.**

It is meant as a spiritual successor of the `colorize` [package](https://github.com/yamadapc/d-colorize) and try to improve it based upon industrial usage of console colors in very important software.

As it is a very competitive field, we'll try to establish some claims using reasoning that this thing is better than some other related things.


## Example

```d
import consolecolors;

void main(string[] args)
{
    cwriteln;
    cwriteln("Welcome to &gt;&gt;&gt; <yellow><on_blue> "
           ~ "console-colors </on_blue></yellow> &lt;&lt;&lt;");
    cwriteln;
    cwritefln("In this library, %s are nestable thanks to a state machine.\n".yellow, 
              " text colors ".lmagenta.on_white);
    cwriteln;
    cwriteln("*** FOREGROUND COLORS".white);
    cwriteln;
    foreach(c; availableConsoleColors)
    {
        cwritefln("    <%s> - %8s </%s> <grey>with &lt;%s&gt; or .%s() </grey>", 
                  c, c, c, c, c);
    }
    cwriteln;
    cwriteln;
    cwriteln("*** BACKGROUND COLORS".white);
    cwriteln;
    foreach(c; availableConsoleColors)
    {
        cwritefln("    <on_%s> <white>- %8s</white> </on_%s> "
                ~ "<grey>with &lt;on_%s&gt; or .on_%s()</grey>", c, c, c, c, c);
    }
}
```

## Features

- Use 16 different colors in the terminal, for foreground and background.

- One file, can be copied in your project.

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
