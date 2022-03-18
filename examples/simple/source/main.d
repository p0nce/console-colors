import consolecolors;
import std.format;


void main(string[] args)
{
    cwriteln;
    cwriteln("Welcome to &gt;&gt;&gt; <yellow><on_blue> console-colors </on_blue></yellow> &lt;&lt;&lt;");
    cwriteln;
    cwriteln( format("In this library, %s are nestable thanks to a state machine.".yellow, " text colors ".lmagenta.on_white));
    cwriteln("\nHere are all available colors:".white);
    cwriteln;
    cwriteln("FOREGROUND COLORS".white);
    cwriteln;
    foreach(c; availableConsoleColors)
    {
        cwritefln("<%s> - %8s </%s> <grey>(with &lt;%s&gt; or .%s() )</grey>", c, c, c, c, c);
    }
    cwriteln;
    cwriteln;
    cwriteln("BACKGROUND COLORS".white);
    cwriteln;
    foreach(c; availableConsoleColors)
    {
        cwritefln("<on_%s> <white>- %8s</white> </on_%s> <grey>(with &lt;on_%s&gt; or .on_%s())</grey>", c, c, c, c, c);
    }
}
